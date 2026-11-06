# Problem 2: Sample Collection Planning using PDDL

The rover Curiosity has two storage bays and must deliver every rock to Base. Soft rocks can be picked up directly. Hard rocks can be picked up only after the drill has been collected, and the drill is then kept for the rest of the mission. The rover may move only along the given routes. SiteC → SiteD is one-way.

The domain and both problems use only `:strips` and `:typing`. There are no numeric fluents, no conditional effects, and no negative preconditions. Delete effects such as `(not (empty ?b))` are ordinary STRIPS deletions, not preconditions.

Planner: **Fast Downward 26.6** (release revision `7ea2755`), run from the `aibasel/downward` image.

| Configuration | Search | Heuristic | What it guarantees |
| :--- | :--- | :--- | :--- |
| Satisficing | Eager greedy best-first search `eager_greedy([hff])` | FF (`ff`) | A valid plan. FF is not admissible, and greedy search stops at the first plan it finds. |
| Optimal | A* `astar(lmcut())`, with reopening | LM-cut (`lmcut`) | A minimum-cost plan. LM-cut is admissible. Every action has cost 1, so this is also a shortest plan. |

Raw logs are in `planner_logs/`. Plans are in `plans/`. Step-by-step simulations are in `verification/`.

## 1. Domain

`Domain.pddl` defines five types: `location`, `rover`, `bay`, `drill`, and `rock`.

| Predicate | Meaning |
| :--- | :--- |
| `(at-rover ?r ?l)` | Rover `?r` is at location `?l`. |
| `(at-rock ?rk ?l)` | Rock `?rk` is lying at location `?l` (not in a bay). |
| `(at-drill ?d ?l)` | Drill `?d` is lying at location `?l`. |
| `(connected ?from ?to)` | The rover may move from `?from` to `?to`. This is directed. |
| `(has-bay ?r ?b)` | Bay `?b` belongs to rover `?r`. Static. |
| `(empty ?b)` | Bay `?b` holds nothing. |
| `(stored ?b ?rk)` | Bay `?b` holds rock `?rk`. |
| `(carrying-drill ?r ?d)` | Rover `?r` is carrying drill `?d`. |
| `(soft ?rk)` / `(hard ?rk)` | Rock type. Both are positive predicates. |

An empty bay is a positive fact, `(empty ?b)`, rather than the absence of a stored rock. Collect deletes it and deposit adds it. That is how the two-bay limit is enforced without a negative precondition.

Actions:

| Action | Preconditions | Effect |
| :--- | :--- | :--- |
| `move` | Rover is at `?from`, and `(connected ?from ?to)` holds. | Rover moves to `?to`. |
| `pick-drill` | Rover and drill are at the same location. | Drill is no longer at that location. `(carrying-drill ...)` is added and never deleted. |
| `collect-soft` | Rover and a soft rock are at the same location, and the chosen bay is empty and belongs to the rover. | Rock leaves the location and occupies the bay. |
| `collect-hard` | Same as collect-soft, the rock is hard, and the rover is carrying the drill. | Rock occupies the bay. |
| `deposit` | The named bay of the rover holds the named rock, and the rover is at `?l`. | Rock is placed at `?l` and the bay becomes empty. |

Soft and hard collection are separate actions because a single action cannot say "if the rock is hard, the drill is required" under pure STRIPS. A hard rock fails the `(soft ?rk)` precondition of `collect-soft`. A soft rock fails the `(hard ?rk)` precondition of `collect-hard`.

## 2. Problems

Locations are `base`, `site-a`, `site-b`, `site-c`, `site-d`, `site-e`, and `site-f`. The rover is `curiosity`, the bays are `bay1` and `bay2`, and the drill is `drill1`.

Routes in `Problem.pddl`:

| Route | Directions |
| :--- | :--- |
| Base — SiteA | both |
| Base — SiteB | both |
| SiteA — SiteC | both |
| SiteB — SiteD | both |
| SiteC — SiteE | both |
| SiteD — SiteE | both |
| SiteE — SiteF | both |
| SiteC → SiteD | one way only |

There is no `(connected site-d site-c)`.

Initial state of the base problem:

| Object | Where | Type |
| :--- | :--- | :--- |
| Curiosity | Base | rover, bays empty, drill not carried |
| Drill1 | SiteE | drill |
| Rock1 | SiteA | soft |
| Rock2 | SiteB | soft |
| Rock3 | SiteC | hard |
| Rock4 | SiteD | soft |
| Rock5 | SiteF | hard |

Goal: Curiosity at Base, Rock1–Rock5 at Base, and both bays empty. A rock fact `(at-rock ... base)` is true only after a deposit, so the rocks must be unloaded, not merely carried into Base.

`Problem_extended.pddl` keeps the same domain and adds:

| Change | Modelling |
| :--- | :--- |
| Rock6, soft, at SiteE | New object, `(soft rock6)`, `(at-rock rock6 site-e)`. |
| Rock7, hard, at SiteF | New object, `(hard rock7)`, `(at-rock rock7 site-f)`. |
| Dust storm closes Base ↔ SiteB | Both `(connected base site-b)` and `(connected site-b base)` are omitted. SiteB ↔ SiteD stays open. |

The extended goal is Rock1–Rock7 at Base, Curiosity at Base, and both bays empty.

## 3. Plans

Plan length and the number of actions are equal in every run because Fast Downward assigns cost 1 to every STRIPS action. The reported plan cost matches the length (25, 30, 40, and 46).

Planning time below is Fast Downward's search time. Translation of each problem took well under 0.05 s and is not included. On the long run the total planner time was 146.325 s, against a search time of 146.321 s.

| Scenario | Configuration | Plan length | Actions | States expanded | States generated | Search time |
| :--- | :--- | ---: | ---: | ---: | ---: | ---: |
| Base | Greedy best-first + FF | 30 | 30 | 51 | 183 | 0.002821 s |
| Base | A* + LM-cut | 25 | 25 | 5,774 | 23,604 | 0.303753 s |
| Extended | Greedy best-first + FF | 46 | 46 | 92 | 369 | 0.005337 s |
| Extended | A* + LM-cut | 40 | 40 | 2,230,074 | 8,993,315 | 146.321412 s |

Initial heuristic values were 17 (base, both heuristics) and 21 (extended, both heuristics). The optimal costs are 25 and 40, so both heuristics underestimate, which is required for LM-cut and happened to be true for FF on these two tasks as well. A* expands many more states because it has to prove that nothing shorter exists. Greedy search follows the heuristic down and stops.

### Base scenario, satisficing (30 actions)

```
(move curiosity base site-a)
(collect-soft curiosity rock1 bay1 site-a)
(move curiosity site-a base)
(deposit curiosity rock1 bay1 base)
(move curiosity base site-b)
(collect-soft curiosity rock2 bay1 site-b)
(move curiosity site-b base)
(deposit curiosity rock2 bay1 base)
(move curiosity base site-a)
(move curiosity site-a site-c)
(move curiosity site-c site-e)
(pick-drill curiosity drill1 site-e)
(move curiosity site-e site-c)
(collect-hard curiosity rock3 bay1 site-c drill1)
(move curiosity site-c site-d)
(collect-soft curiosity rock4 bay2 site-d)
(move curiosity site-d site-b)
(move curiosity site-b base)
(deposit curiosity rock3 bay1 base)
(deposit curiosity rock4 bay2 base)
(move curiosity base site-a)
(move curiosity site-a site-c)
(move curiosity site-c site-e)
(move curiosity site-e site-f)
(collect-hard curiosity rock5 bay1 site-f drill1)
(move curiosity site-f site-e)
(move curiosity site-e site-c)
(move curiosity site-c site-a)
(move curiosity site-a base)
(deposit curiosity rock5 bay1 base)
```

### Base scenario, optimal (25 actions)

```
(move curiosity base site-b)
(collect-soft curiosity rock2 bay1 site-b)
(move curiosity site-b site-d)
(collect-soft curiosity rock4 bay2 site-d)
(move curiosity site-d site-b)
(move curiosity site-b base)
(deposit curiosity rock2 bay1 base)
(deposit curiosity rock4 bay2 base)
(move curiosity base site-a)
(move curiosity site-a site-c)
(move curiosity site-c site-e)
(pick-drill curiosity drill1 site-e)
(move curiosity site-e site-f)
(collect-hard curiosity rock5 bay1 site-f drill1)
(move curiosity site-f site-e)
(move curiosity site-e site-c)
(collect-hard curiosity rock3 bay2 site-c drill1)
(move curiosity site-c site-a)
(move curiosity site-a base)
(deposit curiosity rock3 bay2 base)
(deposit curiosity rock5 bay1 base)
(move curiosity base site-a)
(collect-soft curiosity rock1 bay1 site-a)
(move curiosity site-a base)
(deposit curiosity rock1 bay1 base)
```

### Extended scenario, satisficing (46 actions)

```
(move curiosity base site-a)
(collect-soft curiosity rock1 bay1 site-a)
(move curiosity site-a base)
(deposit curiosity rock1 bay1 base)
(move curiosity base site-a)
(move curiosity site-a site-c)
(move curiosity site-c site-e)
(pick-drill curiosity drill1 site-e)
(move curiosity site-e site-c)
(collect-hard curiosity rock3 bay1 site-c drill1)
(move curiosity site-c site-a)
(move curiosity site-a base)
(deposit curiosity rock3 bay1 base)
(move curiosity base site-a)
(move curiosity site-a site-c)
(move curiosity site-c site-d)
(move curiosity site-d site-b)
(collect-soft curiosity rock2 bay1 site-b)
(move curiosity site-b site-d)
(collect-soft curiosity rock4 bay2 site-d)
(move curiosity site-d site-e)
(move curiosity site-e site-c)
(move curiosity site-c site-a)
(move curiosity site-a base)
(deposit curiosity rock2 bay1 base)
(deposit curiosity rock4 bay2 base)
(move curiosity base site-a)
(move curiosity site-a site-c)
(move curiosity site-c site-e)
(move curiosity site-e site-f)
(collect-hard curiosity rock5 bay1 site-f drill1)
(collect-hard curiosity rock7 bay2 site-f drill1)
(move curiosity site-f site-e)
(move curiosity site-e site-c)
(move curiosity site-c site-a)
(move curiosity site-a base)
(deposit curiosity rock5 bay1 base)
(deposit curiosity rock7 bay2 base)
(move curiosity base site-a)
(move curiosity site-a site-c)
(move curiosity site-c site-e)
(collect-soft curiosity rock6 bay1 site-e)
(move curiosity site-e site-c)
(move curiosity site-c site-a)
(move curiosity site-a base)
(deposit curiosity rock6 bay1 base)
```

### Extended scenario, optimal (40 actions)

```
(move curiosity base site-a)
(move curiosity site-a site-c)
(move curiosity site-c site-d)
(collect-soft curiosity rock4 bay1 site-d)
(move curiosity site-d site-b)
(collect-soft curiosity rock2 bay2 site-b)
(move curiosity site-b site-d)
(move curiosity site-d site-e)
(pick-drill curiosity drill1 site-e)
(move curiosity site-e site-c)
(move curiosity site-c site-a)
(move curiosity site-a base)
(deposit curiosity rock2 bay2 base)
(deposit curiosity rock4 bay1 base)
(move curiosity base site-a)
(move curiosity site-a site-c)
(move curiosity site-c site-e)
(move curiosity site-e site-f)
(collect-hard curiosity rock5 bay1 site-f drill1)
(collect-hard curiosity rock7 bay2 site-f drill1)
(move curiosity site-f site-e)
(move curiosity site-e site-c)
(move curiosity site-c site-a)
(move curiosity site-a base)
(deposit curiosity rock5 bay1 base)
(deposit curiosity rock7 bay2 base)
(move curiosity base site-a)
(move curiosity site-a site-c)
(collect-hard curiosity rock3 bay1 site-c drill1)
(move curiosity site-c site-e)
(collect-soft curiosity rock6 bay2 site-e)
(move curiosity site-e site-c)
(move curiosity site-c site-a)
(move curiosity site-a base)
(deposit curiosity rock3 bay1 base)
(deposit curiosity rock6 bay2 base)
(move curiosity base site-a)
(collect-soft curiosity rock1 bay1 site-a)
(move curiosity site-a base)
(deposit curiosity rock1 bay1 base)
```

## 4. Goal verification

VAL is not installed in the Fast Downward image (`validate` was absent from `PATH`), so each plan was checked by executing it from the problem's initial state. `verify_plan.py` applies one action at a time and rejects an action whose precondition is false. For every action it checks the rover's location, that a move uses a `connected` fact from that problem (so the missing SiteD → SiteC link and, in the extended problem, the closed Base ↔ SiteB road cannot be used), that a bay is empty before a collect, that soft and hard actions match the rock, that a hard collect happens only while the drill is carried, and that a deposit removes the rock that is actually in that bay.

All four plans run to completion with every precondition satisfied. Full traces:

| Plan | Trace |
| :--- | :--- |
| Base, satisficing | `verification/scenario1_satisficing.txt` |
| Base, optimal | `verification/scenario1_optimal.txt` |
| Extended, satisficing | `verification/scenario2_satisficing.txt` |
| Extended, optimal | `verification/scenario2_optimal.txt` |

### Final state, base scenario (both plans)

```
rover@base; drill carried; bay1=empty, bay2=empty
rock1@base, rock2@base, rock3@base, rock4@base, rock5@base
```

| Goal literal | Result |
| :--- | :--- |
| `(at-rover curiosity base)` | holds |
| `(at-rock rock1 base)` … `(at-rock rock5 base)` | all hold |
| `(empty bay1)`, `(empty bay2)` | both hold |

The drill is still carried. The mission statement says the rover keeps the drill once it has been picked up, and the goal does not ask for the drill to be put down.

### Final state, extended scenario (both plans)

```
rover@base; drill carried; bay1=empty, bay2=empty
rock1@base, rock2@base, rock3@base, rock4@base, rock5@base, rock6@base, rock7@base
```

Rock1–Rock7 are at Base, both bays are empty, and Curiosity is at Base.

## 5. How the plans differ

### Length

| Scenario | Satisficing | Optimal | Extra actions in the greedy plan |
| :--- | ---: | ---: | ---: |
| Base | 30 | 25 | 5 |
| Extended | 46 | 40 | 6 |

Greedy best-first search orders states by the FF heuristic alone and returns the first goal state it expands. FF is computed on the delete relaxation, so it ignores the deletion of `(empty ?bay)`. It therefore underestimates the cost of trips that leave a bay idle. The plans it returns are valid, and on these two tasks they are only a few actions above optimal, because the heuristic value at the initial state (17 and 21) is already close to the optimal cost (25 and 40). They are still longer, and the extra actions are extra driving.

A* expands states in order of `f = g + h` with an admissible `h`. The first time the goal is selected for expansion, `g` is the optimal cost. That certificate is why the optimal runs expand 5,774 states instead of 51, and 2,230,074 states instead of 92. The extended task is harder for the proof: seven rocks and a removed road push the optimal cost to 40 while LM-cut at the root is only 21, and the search has to close that gap.

### Base scenario: where the five actions go

The optimal plan makes three sorties.

| Sortie | Steps | Bay1 | Bay2 | What happens |
| :--- | :--- | :--- | :--- | :--- |
| 1 | 1–8 | Rock2 | Rock4 | East loop Base → SiteB → SiteD → SiteB → Base. Both soft rocks on that branch come home together. The drill is not needed. |
| 2 | 9–21 | Rock5 | Rock3 | Base → SiteA → SiteC → SiteE, pick up the drill, SiteE → SiteF, collect Rock5, and on the way home SiteE → SiteC collect Rock3. Both bays are used on the long SiteF trip. |
| 3 | 22–25 | Rock1 | empty | Rock1 is one hop from Base, so the second bay cannot shorten this trip. |

The drill is picked up at **step 12**, at SiteE, after Rock2 and Rock4 are already deposited and before either hard rock is collected. Rock5 is collected at step 14 and Rock3 at step 17. The rover passes SiteC on the way out, before it has the drill, so Rock3 has to wait for the return. The optimal plan does that return with a free bay.

The greedy plan also has a four-action Rock1 trip, so that trip is not the source of the gap. It then does three things the optimal plan avoids:

1. It delivers Rock2 alone (steps 5–8), with Bay2 empty, instead of filling Bay2 with Rock4 on the same loop.
2. It pairs Rock3 with Rock4, using the one-way slope SiteC → SiteD (step 15). That pairing is legal, and it does use both bays, but it splits the two east-side soft rocks apart.
3. It then drives Base → SiteA → SiteC → SiteE → SiteF and all the way back carrying only Rock5 (steps 21–30). Bay2 is empty for the whole of the longest trip in the problem.

Those extra crossings are five moves. Both plans collect five rocks, deposit five rocks, and pick up the drill once. The optimal plan simply does that collection in 14 moves rather than 19.

The optimal base plan never uses SiteC → SiteD. SiteD is reached from SiteB, and SiteC is reached from SiteA.

### Extended scenario: bays, the drill, and the closed road

The dust storm removes Base ↔ SiteB. SiteB is then reachable only through SiteD, and SiteD is reachable from the west only by SiteC → SiteD or by SiteC → SiteE → SiteD. The road back is forced: SiteD → SiteC does not exist, and SiteB → Base does not exist, so the rover returns SiteB → SiteD → SiteE → SiteC → SiteA → Base. SiteE is on every return from the eastern branch. The drill starts at SiteE, so the first eastern sortie can pick it up without a detour.

The optimal plan does that. Its four sorties:

| Sortie | Steps | Bay1 | Bay2 | What happens |
| :--- | :--- | :--- | :--- | :--- |
| 1 | 1–14 | Rock4 | Rock2 | Base → SiteA → SiteC → **SiteD** (one-way) → SiteB. Both eastern soft rocks fill the bays. Return SiteB → SiteD → SiteE, **pick up the drill at step 9**, then SiteE → SiteC → SiteA → Base. Both bays are full at SiteE, so Rock6 stays there. |
| 2 | 15–26 | Rock5 | Rock7 | One visit to SiteF collects both hard rocks that sit there. |
| 3 | 27–36 | Rock3 | Rock6 | Rock3 at SiteC, then Rock6 at SiteE, then home. The drill is already on board. |
| 4 | 37–40 | Rock1 | empty | Same one-hop delivery as in the base problem. |

The one-way route **is used**, once, at step 3 (`move curiosity site-c site-d`). That is how the rover first reaches SiteD, and the next move, step 5 (`move curiosity site-d site-b`), is how it reaches SiteB. It never travels SiteD → SiteC, and it never travels between Base and SiteB.

The drill is picked up at **step 9**, at SiteE, while Bay1 still holds Rock4 and Bay2 still holds Rock2. The first hard rocks are Rock5 and Rock7, collected at steps 19 and 20. Rock3 is collected later, at step 29. No hard rock is collected before step 9.

The greedy extended plan uses the same corridor into the east: step 16 is `move curiosity site-c site-d`, then step 17 enters SiteB, and the return is again SiteB → SiteD → SiteE → SiteC → SiteA → Base. The one-way route is used there too. The extra six actions come from how the bays are filled around the drill, not from a different route around the storm.

| Rocks | Satisficing | Optimal |
| :--- | :--- | :--- |
| Rock1 | 4 actions, Bay2 idle | 4 actions, Bay2 idle |
| Rock5 and Rock7 | 12 actions, both bays, one SiteF visit | 12 actions, same pairing |
| Drill, Rock2, Rock3, Rock4, Rock6 | 9 (drill and Rock3 alone) + 13 (Rock2 and Rock4) + 8 (Rock6 alone) = 30 | 14 (Rock2, Rock4, and the drill on the forced return through SiteE) + 10 (Rock3 and Rock6 together) = 24 |

Rock1 and the SiteF pair cost the same in both plans (16 actions). The other five rocks and the drill cost 30 in the greedy plan and 24 in the optimal plan. The greedy plan spends a trip picking up the drill in order to bring back only Rock3, leaves Rock6 for a later solo trip, and only then uses both bays on the eastern soft rocks. The optimal plan fills both bays on that eastern trip, takes the drill on the way home because SiteE is already on the return, and later fills both bays again with Rock3 and Rock6.

## 6. Reproduce

From `Problem2`, with Docker:

```bash
docker pull aibasel/downward:latest
python run_planners.py
python verify_plan.py Problem.pddl plans/scenario1_optimal.soln
python verify_plan.py Problem_extended.pddl plans/scenario2_optimal.soln
```

`run_planners.py` runs the four searches above and writes `plans/` and `planner_logs/`. The checked-in logs are the runs reported in this document.
