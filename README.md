# AI Group Assignment 2 - Hacker Gang

## Team Members
| Name | Roll Number |
| :--- | :--- |
| Harshit Kandpal | B24CS505 |
| Vedant Chandak | B24EC039 |
| Sujal Som | B24DS032 |
| Tanmay Jaiswal | B24DS033 |
| Sourav Singh Yadav | B24EC032 |

---

## Repository Structure
```
.
├── names.txt
├── assignment.md
├── README.md
└── Problem3/
    ├── royal_archive_access.pl
    └── output.png
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
