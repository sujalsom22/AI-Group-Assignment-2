"""Reproduce the four Fast Downward runs for Problem 2.

Satisficing: eager greedy best-first search with the FF heuristic.
Optimal: A* with LM-cut, which is admissible, so the plan cost is optimal.
Every action has cost 1, so plan length equals the number of actions.

Requires Docker and the image aibasel/downward:latest:

    docker pull aibasel/downward:latest
    python run_planners.py
"""

from __future__ import annotations

import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parent
IMAGE = "aibasel/downward:latest"

RUNS = [
    (
        "scenario1_satisficing",
        "Problem.pddl",
        "let(hff, ff(), eager_greedy([hff]))",
    ),
    (
        "scenario1_optimal",
        "Problem.pddl",
        "astar(lmcut())",
    ),
    (
        "scenario2_satisficing",
        "Problem_extended.pddl",
        "let(hff, ff(), eager_greedy([hff]))",
    ),
    (
        "scenario2_optimal",
        "Problem_extended.pddl",
        "astar(lmcut())",
    ),
]


def main() -> None:
    (ROOT / "plans").mkdir(exist_ok=True)
    (ROOT / "planner_logs").mkdir(exist_ok=True)
    for name, problem, search in RUNS:
        log_path = ROOT / "planner_logs" / f"{name}.log"
        command = [
            "docker",
            "run",
            "--rm",
            "-v",
            f"{ROOT}:/files",
            IMAGE,
            "--plan-file",
            f"/files/plans/{name}.soln",
            "--sas-file",
            f"/tmp/{name}.sas",
            "/files/Domain.pddl",
            f"/files/{problem}",
            "--search",
            search,
        ]
        print(f"=== {name}: {search} ===", flush=True)
        completed = subprocess.run(command, capture_output=True, text=True)
        log_path.write_text(
            completed.stdout + completed.stderr,
            encoding="utf-8",
            newline="\n",
        )
        print(f"exit {completed.returncode}", flush=True)
        if completed.returncode != 0:
            raise SystemExit(completed.returncode)


if __name__ == "__main__":
    main()
