PROBLEM 3: ROYAL ARCHIVE
ACCESS VERIFICATION USING
RESOLUTION REFUTATION

Background
A royal archive stores sealed historical records. Before a person can be trusted with an
archive record, the person’s role and actions must satisfy a sequence of logical rules. The
archive team wants to use First-Order Predicate Logic (FOL) and Prolog to verify whether
a particular person should be considered trusted.
Your task is to represent the knowledge as logical rules, convert the formulas into clause
form, and use Resolution Refutation to prove the required conclusion.

Facts and Rules
1. Every archivist who verifies a record is trusted.
2. Every trusted person who has access to a sealed record is permitted to inspect that
record. (Being permitted to inspect is different from actually inspecting.)
3. Anyone who inspects a record and finds a hidden mark in it verifies that record.
4. Every record stored in the royal archive is sealed.
5. scroll_7 is stored in the royal archive.
6. Mira has access to scroll_7.
7. Mira inspects scroll_7 and finds a hidden mark in it.
8. Mira is an archivist.

Goal
Prove that: Mira is trusted.
Use the Resolution Refutation method in First-Order Predicate Logic (FOL).

Tasks
Task 1: Knowledge Representation
Represent all facts and rules in First-Order Predicate Logic. Clearly identify predicates,
constants, and variables.

Task 2: Negate the Goal
Add the negation of the goal to the knowledge base for resolution refutation.

Task 3: Convert to Clause Form
Remove implications, move negations inward, standardize variables apart, perform
Skolemization where necessary, and convert all formulas into CNF clauses.

Task 4: Prolog Implementation
Create a Prolog program that records each transformation stage in separate sections or
predicates.

Task 5: Resolution Refutation
Implement or use a resolution procedure to show each resolvent in order. Continue until the
empty clause ([]) is derived.

Task 6: Proof Verification
Run the program and verify that the empty clause is produced, proving the goal follows from
the facts and rules.

Expected Prolog File Structure
% Step 1: Predicate logic representation
% Step 2: Negation of goal
% Step 3: Implication removal
% Step 4: Negation movement
% Step 5: Standardization
% Step 6: Skolemization
% Step 7: CNF clauses
% Step 8: Resolution implementation and execution

Deliverables
1. A single Prolog file (royal_archive_access.pl) containing:
The code and comments for all transformation steps.
The resolution refutation process showing the derivation of the empty clause.

2. A screenshot of the final proof output showing the empty clause or contradiction.

Challenge
The proof requires combining multiple rules to derive intermediate predicates before reaching
the goal. Do not assume the conclusion directly; show the chain of reasoning through
resolution. Note that not every rule