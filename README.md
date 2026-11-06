# AI Group Assignment 2 - Hacker Gang

## Team Members
| Name | Roll Number | Assigned Problem |
| :--- | :--- | :--- |
| Harshit Kandpal (Problem 3) | B24CS505 | Problem 3 |
| Vedant Chandak | B24EC039 | |
| Sujal Som | B24DS032 | |
| Tanmay Jaiswal | B24DS033 | |

---

## Repository Structure
```
.
├── names.txt
├── README.md
├── Problem2/
│   ├── Domain.pddl
│   ├── Problem.pddl
│   ├── Problem_extended.pddl
│   ├── ANALYSIS.md
│   ├── plans/
│   ├── planner_logs/
│   └── verification/
└── Problem3/
    ├── royal_archive_access.pl
    └── output.png
```

---

## Problem 2: Sample Collection Planning using PDDL

### Overview
An autonomous Mars rover with two storage bays collects five rocks (seven in the extended scenario) and returns them to Base. Hard rocks require a drill, and the slope from SiteC to SiteD can be travelled in only one direction. The extended scenario adds two rocks and closes Base ↔ SiteB.

The model uses only `:strips` and `:typing`. Plans were generated with Fast Downward 26.6: greedy best-first search with the FF heuristic, and A* with the admissible LM-cut heuristic. Step-by-step simulation confirms that every plan leaves all rocks at Base, both bays empty, and the rover at Base.

| Scenario | Satisficing length | Optimal length |
| :--- | ---: | ---: |
| Base (5 rocks) | 30 | 25 |
| Extended (7 rocks, dust storm) | 46 | 40 |

The full comparison, action sequences, final states, and route analysis are in [Problem2/ANALYSIS.md](Problem2/ANALYSIS.md).

### How to Run

Docker is required for planning. Verification uses Python only.

```bash
cd Problem2
docker pull aibasel/downward:latest
python run_planners.py
python verify_plan.py Problem.pddl plans/scenario1_optimal.soln
python verify_plan.py Problem_extended.pddl plans/scenario2_optimal.soln
```

---

## Problem 3: Royal Archive Access Verification using Resolution Refutation

### Overview
This project models a royal archive access security policy in First-Order Predicate Logic (FOL) and verifies through Prolog and Resolution Refutation whether a given individual (`mira`) should be considered trusted (`trusted(mira)`).

### Facts & Rules
1. Every archivist who verifies a record is trusted.
2. Every trusted person who has access to a sealed record is permitted to inspect that record.
3. Anyone who inspects a record and finds a hidden mark in it verifies that record.
4. Every record stored in the royal archive is sealed.
5. `scroll_7` is stored in the royal archive.
6. Mira has access to `scroll_7`.
7. Mira inspects `scroll_7` and finds a hidden mark in it.
8. Mira is an archivist.

### Goal
Prove that: **Mira is trusted** (`trusted(mira)`) using Resolution Refutation.

---

## How to Run

Ensure SWI-Prolog (`swipl`) is installed.

```bash
# Navigate to Problem3 directory
cd Problem3

# Run the resolution refutation proof
swipl -s royal_archive_access.pl -g "prove, halt."

# Or verify via native Prolog Horn clause inference
swipl -s royal_archive_access.pl -g "verify_trusted, halt."
```

### Output
The proof derives the empty clause `[]` demonstrating a contradiction with the negated goal `not(trusted(mira))`, confirming that `trusted(mira)` holds.
Screenshot is saved at [Problem3/output.png](Problem3/output.png).
