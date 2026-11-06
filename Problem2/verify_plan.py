"""Step-by-step STRIPS simulator for the Mars sample-collection domain.

Replays a pyperplan solution against the initial state of a problem file,
checks every precondition, and reports the final state plus the goal literals.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path


LOCATIONS = ["base", "site-a", "site-b", "site-c", "site-d", "site-e", "site-f"]
BAYS = ["bay1", "bay2"]


def _atoms(block: str) -> list[tuple[str, ...]]:
    """Extract top-level s-expressions from a PDDL init or goal block."""
    atoms: list[tuple[str, ...]] = []
    i = 0
    while True:
        start = block.find("(", i)
        if start < 0:
            break
        depth = 0
        for j in range(start, len(block)):
            if block[j] == "(":
                depth += 1
            elif block[j] == ")":
                depth -= 1
                if depth == 0:
                    body = block[start + 1 : j].strip()
                    parts = body.split()
                    if parts and parts[0] != "and":
                        atoms.append(tuple(parts))
                    i = j + 1
                    break
        else:
            break
    return atoms


def parse_problem(path: Path) -> dict:
    text = path.read_text(encoding="utf-8")
    text = re.sub(r";[^\n]*", "", text)
    init_match = re.search(r"\(:init(.*)\)\s*\(:goal", text, re.S)
    goal_match = re.search(r"\(:goal\s*\(and(.*)\)\s*\)\s*\)\s*$", text, re.S)
    if not init_match or not goal_match:
        raise ValueError(f"Could not parse init/goal from {path}")

    rocks: dict[str, str] = {}
    hardness: dict[str, str] = {}
    connected: set[tuple[str, str]] = set()
    drill_at = None
    rover_at = None
    empty = set()
    for atom in _atoms(init_match.group(1)):
        name, *args = atom
        if name == "at-rover":
            rover_at = args[1]
        elif name == "at-rock":
            rocks[args[0]] = args[1]
        elif name == "at-drill":
            drill_at = args[1]
        elif name == "empty":
            empty.add(args[0])
        elif name in ("soft", "hard"):
            hardness[args[0]] = name
        elif name == "connected":
            connected.add((args[0], args[1]))

    goal = _atoms(goal_match.group(1))
    return {
        "rover_at": rover_at,
        "rocks": rocks,
        "drill_at": drill_at,
        "carrying_drill": False,
        "empty": empty,
        "stored": {},  # bay -> rock
        "hardness": hardness,
        "connected": connected,
        "goal": goal,
    }


def parse_plan(path: Path) -> list[tuple[str, ...]]:
    actions = []
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.strip().lower()
        if not line or line.startswith(";"):
            continue
        if line.startswith("(") and line.endswith(")"):
            actions.append(tuple(line[1:-1].split()))
    return actions


def _fail(step: int, action: tuple[str, ...], message: str) -> None:
    raise AssertionError(f"Step {step} {format_action(action)}: {message}")


def format_action(action: tuple[str, ...]) -> str:
    return "(" + " ".join(action) + ")"


def apply_action(state: dict, action: tuple[str, ...], step: int) -> None:
    name = action[0]
    rover = state["rover_at"]

    if name == "move":
        _, _rover, src, dst = action
        if rover != src:
            _fail(step, action, f"rover is at {rover}, not {src}")
        if (src, dst) not in state["connected"]:
            _fail(step, action, f"no route from {src} to {dst}")
        state["rover_at"] = dst
        return

    if name == "pick-drill":
        _, _rover, _drill, loc = action
        if rover != loc:
            _fail(step, action, f"rover is at {rover}, not {loc}")
        if state["drill_at"] != loc:
            _fail(step, action, f"drill is at {state['drill_at']}, not {loc}")
        if state["carrying_drill"]:
            _fail(step, action, "rover is already carrying the drill")
        state["drill_at"] = None
        state["carrying_drill"] = True
        return

    if name == "collect-soft":
        _, _rover, rock, bay, loc = action
        _collect(state, action, step, rock, bay, loc, need_drill=False)
        return

    if name == "collect-hard":
        _, _rover, rock, bay, loc, _drill = action
        _collect(state, action, step, rock, bay, loc, need_drill=True)
        return

    if name == "deposit":
        _, _rover, rock, bay, loc = action
        if rover != loc:
            _fail(step, action, f"rover is at {rover}, not {loc}")
        if state["stored"].get(bay) != rock:
            _fail(step, action, f"{bay} holds {state['stored'].get(bay)}, not {rock}")
        del state["stored"][bay]
        state["empty"].add(bay)
        state["rocks"][rock] = loc
        return

    _fail(step, action, "unknown action")


def _collect(state, action, step, rock, bay, loc, need_drill: bool) -> None:
    if state["rover_at"] != loc:
        _fail(step, action, f"rover is at {state['rover_at']}, not {loc}")
    if state["rocks"].get(rock) != loc:
        _fail(step, action, f"{rock} is at {state['rocks'].get(rock)}, not {loc}")
    if bay not in state["empty"]:
        _fail(step, action, f"{bay} is not empty")
    kind = state["hardness"].get(rock)
    if need_drill:
        if kind != "hard":
            _fail(step, action, f"{rock} is {kind}, not hard")
        if not state["carrying_drill"]:
            _fail(step, action, "hard rock requires the drill")
    else:
        if kind != "soft":
            _fail(step, action, f"{rock} is {kind}, not soft")
    del state["rocks"][rock]
    state["empty"].remove(bay)
    state["stored"][bay] = rock


def snapshot(state: dict) -> str:
    rocks = []
    for rock in sorted(state["hardness"]):
        if rock in state["rocks"]:
            rocks.append(f"{rock}@{state['rocks'][rock]}")
        else:
            bay = next(b for b, r in state["stored"].items() if r == rock)
            rocks.append(f"{rock} in {bay}")
    drill = "carried" if state["carrying_drill"] else f"at {state['drill_at']}"
    bays = []
    for bay in BAYS:
        bays.append(f"{bay}={state['stored'].get(bay, 'empty')}")
    return (
        f"rover@{state['rover_at']}; drill {drill}; "
        + ", ".join(bays)
        + "; "
        + ", ".join(rocks)
    )


def goal_report(state: dict) -> tuple[bool, list[str]]:
    lines = []
    ok = True
    for atom in state["goal"]:
        name, *args = atom
        holds = False
        if name == "at-rover":
            holds = state["rover_at"] == args[1]
        elif name == "at-rock":
            holds = state["rocks"].get(args[0]) == args[1]
        elif name == "empty":
            holds = args[0] in state["empty"] and args[0] not in state["stored"]
        else:
            holds = False
        mark = "OK" if holds else "MISSING"
        if not holds:
            ok = False
        lines.append(f"  [{mark}] ({' '.join(atom)})")
    return ok, lines


def simulate(problem_path: Path, plan_path: Path) -> str:
    state = parse_problem(problem_path)
    actions = parse_plan(plan_path)
    out = [f"Problem: {problem_path.name}", f"Plan: {plan_path.name}", f"Actions: {len(actions)}", ""]
    out.append("Step 0 (initial)")
    out.append("  " + snapshot(state))
    for i, action in enumerate(actions, start=1):
        apply_action(state, action, i)
        out.append(f"Step {i}: {format_action(action)}")
        out.append("  " + snapshot(state))
    out.append("")
    out.append("Final state")
    out.append("  " + snapshot(state))
    out.append("Goal literals")
    ok, lines = goal_report(state)
    out.extend(lines)
    out.append("")
    out.append("GOAL SATISFIED" if ok else "GOAL NOT SATISFIED")
    text = "\n".join(out) + "\n"
    if not ok:
        raise SystemExit(text)
    return text


def main() -> None:
    if len(sys.argv) != 3:
        print("Usage: python verify_plan.py <problem.pddl> <plan.soln>")
        raise SystemExit(2)
    text = simulate(Path(sys.argv[1]), Path(sys.argv[2]))
    sys.stdout.write(text)


if __name__ == "__main__":
    main()
