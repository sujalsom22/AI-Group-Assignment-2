% ______________________________________________________________________________
% Problem 3: Royal Archive Access Verification using Resolution Refutation
% File: royal_archive_access.pl
%
% Given Facts and Rules:
% 1. Every archivist who verifies a record is trusted.
% 2. Every trusted person who has access to a sealed record is permitted to
%    inspect that record. (Being permitted to inspect is different from actually inspecting.)
% 3. Anyone who inspects a record and finds a hidden mark in it verifies that record.
% 4. Every record stored in the royal archive is sealed.
% 5. scroll_7 is stored in the royal archive.
% 6. Mira has access to scroll_7.
% 7. Mira inspects scroll_7 and finds a hidden mark in it.
% 8. Mira is an archivist.
%
% Goal to Prove:
% Mira is trusted (trusted(mira))
% Using Resolution Refutation in First-Order Predicate Logic (FOL).
% ______________________________________________________________________________

:- style_check(-singleton).


% Step 1: Predicate logic representation


% Knowledge base rules (Direct Horn clauses for native Prolog inference verification):
archivist(mira).
stored_in_royal_archive(scroll_7).
has_access(mira, scroll_7).
inspects(mira, scroll_7).
finds_hidden_mark(mira, scroll_7).

sealed(Y) :- stored_in_royal_archive(Y).
verifies(X, Y) :- inspects(X, Y), finds_hidden_mark(X, Y).
trusted(X) :- archivist(X), verifies(X, _Y).
permitted_to_inspect(X, Y) :- trusted(X), has_access(X, Y), sealed(Y).

verify_trusted :-
    (   trusted(mira) ->
        writeln('Verification Success: Mira is trusted.')
    ;   writeln('Verification Failed: Mira is not trusted.')
    ).

% First-order logic representations:
% Constants:
%   mira, scroll_7
%
% Predicates:
%   archivist(X)                 : X is an archivist
%   trusted(X)                   : X is trusted
%   inspects(X, Y)               : X inspects record Y
%   finds_hidden_mark(X, Y)      : X finds a hidden mark in record Y
%   verifies(X, Y)               : X verifies record Y
%   has_access(X, Y)             : X has access to record Y
%   sealed(Y)                    : Record Y is sealed
%   stored_in_royal_archive(Y)   : Record Y is stored in the royal archive
%   permitted_to_inspect(X, Y)   : X is permitted to inspect record Y

fol(rule1, all(X, all(Y, implies(and(archivist(X), verifies(X, Y)), trusted(X))))).
fol(rule2, all(X, all(Y, implies(and(trusted(X), and(has_access(X, Y), sealed(Y))), permitted_to_inspect(X, Y))))).
fol(rule3, all(X, all(Y, implies(and(inspects(X, Y), finds_hidden_mark(X, Y)), verifies(X, Y))))).
fol(rule4, all(Y, implies(stored_in_royal_archive(Y), sealed(Y)))).
fol(fact5, stored_in_royal_archive(scroll_7)).
fol(fact6, has_access(mira, scroll_7)).
fol(fact7, and(inspects(mira, scroll_7), finds_hidden_mark(mira, scroll_7))).
fol(fact8, archivist(mira)).
fol(goal,  trusted(mira)).



% Step 2: Negation of goal


% Negating the goal to perform proof by refutation:
% Goal         : trusted(mira)
% Negated Goal : not(trusted(mira))

negate_goal(Goal, not(Goal)).



% Step 3: Implication removal


% Replace implication (A -> B) with (~A v B):
% Rule 1: not(archivist(X) and verifies(X, Y)) v trusted(X)
% Rule 2: not(trusted(X) and has_access(X, Y) and sealed(Y)) v permitted_to_inspect(X, Y)
% Rule 3: not(inspects(X, Y) and finds_hidden_mark(X, Y)) v verifies(X, Y)
% Rule 4: not(stored_in_royal_archive(Y)) v sealed(Y)

remove_implication(implies(A, B), or(not(A), B)).
remove_implication(all(X, implies(A, B)), all(X, or(not(A), B))).
remove_implication(all(X, all(Y, implies(A, B))), all(X, all(Y, or(not(A), B)))).



% Step 4: Negation movement


% Move negations inward using De Morgan's laws:
% ~(A and B) => ~A v ~B
% Rule 1: not(archivist(X)) v not(verifies(X, Y)) v trusted(X)
% Rule 2: not(trusted(X)) v not(has_access(X, Y)) v not(sealed(Y)) v permitted_to_inspect(X, Y)
% Rule 3: not(inspects(X, Y)) v not(finds_hidden_mark(X, Y)) v verifies(X, Y)
% Rule 4: not(stored_in_royal_archive(Y)) v sealed(Y)
% All negations now apply directly to atomic predicates.



% Step 5: Standardization


% Standardize variable names apart so each clause has unique variables:
% Clause 1 : not(archivist(X1)) v not(verifies(X1, Y1)) v trusted(X1)
% Clause 2 : not(trusted(X2)) v not(has_access(X2, Y2)) v not(sealed(Y2)) v permitted_to_inspect(X2, Y2)
% Clause 3 : not(inspects(X3, Y3)) v not(finds_hidden_mark(X3, Y3)) v verifies(X3, Y3)
% Clause 4 : not(stored_in_royal_archive(Y4)) v sealed(Y4)
% Clause 5 : stored_in_royal_archive(scroll_7)
% Clause 6 : has_access(mira, scroll_7)
% Clause 7a: inspects(mira, scroll_7)
% Clause 7b: finds_hidden_mark(mira, scroll_7)
% Clause 8 : archivist(mira)
% Clause 9 : not(trusted(mira))



% Step 6: Skolemization


% No existential quantifiers present; universal quantifiers dropped.
% Formulas in clause form:
% 1. not(archivist(X1)) v not(verifies(X1, Y1)) v trusted(X1)
% 2. not(trusted(X2)) v not(has_access(X2, Y2)) v not(sealed(Y2)) v permitted_to_inspect(X2, Y2)
% 3. not(inspects(X3, Y3)) v not(finds_hidden_mark(X3, Y3)) v verifies(X3, Y3)
% 4. not(stored_in_royal_archive(Y4)) v sealed(Y4)
% 5. stored_in_royal_archive(scroll_7)
% 6. has_access(mira, scroll_7)
% 7a. inspects(mira, scroll_7)
% 7b. finds_hidden_mark(mira, scroll_7)
% 8. archivist(mira)
% 9. not(trusted(mira))



% Step 7: CNF clauses


% Represent each clause as a list of literals:
cnf_clause(c1,  [not(archivist(X1)), not(verifies(X1, Y1)), trusted(X1)]).
cnf_clause(c2,  [not(trusted(X2)), not(has_access(X2, Y2)), not(sealed(Y2)), permitted_to_inspect(X2, Y2)]).
cnf_clause(c3,  [not(inspects(X3, Y3)), not(finds_hidden_mark(X3, Y3)), verifies(X3, Y3)]).
cnf_clause(c4,  [not(stored_in_royal_archive(Y4)), sealed(Y4)]).
cnf_clause(c5,  [stored_in_royal_archive(scroll_7)]).
cnf_clause(c6,  [has_access(mira, scroll_7)]).
cnf_clause(c7a, [inspects(mira, scroll_7)]).
cnf_clause(c7b, [finds_hidden_mark(mira, scroll_7)]).
cnf_clause(c8,  [archivist(mira)]).
cnf_clause(c9,  [not(trusted(mira))]).



% Step 8: Resolution implementation and execution


% Complementary literals definition:
complementary(not(P), P).
complementary(P, not(P)).

% Resolution rule:
resolve(C1, C2, Resolvent) :-
    select(L1, C1, Rem1),
    select(L2, C2, Rem2),
    complementary(L1, L2),
    append(Rem1, Rem2, Temp),
    sort(Temp, Resolvent).

% Main execution demonstrating CNF clauses and resolution refutation steps:
prove :-
    nl,
    writeln('________________________________________________________________________'),
    writeln('  Royal Archive Access Verification - Resolution Proof'),
    writeln('________________________________________________________________________'),
    nl,

    % Retrieve CNF clauses
    cnf_clause(c1, C1),
    cnf_clause(c2, C2),
    cnf_clause(c3, C3),
    cnf_clause(c4, C4),
    cnf_clause(c5, C5),
    cnf_clause(c6, C6),
    cnf_clause(c7a, C7a),
    cnf_clause(c7b, C7b),
    cnf_clause(c8, C8),
    cnf_clause(c9, C9),

    writeln('CNF Clauses:'),
    write('  C1  : '), writeln(C1),
    write('  C2  : '), writeln(C2),
    write('  C3  : '), writeln(C3),
    write('  C4  : '), writeln(C4),
    write('  C5  : '), writeln(C5),
    write('  C6  : '), writeln(C6),
    write('  C7a : '), writeln(C7a),
    write('  C7b : '), writeln(C7b),
    write('  C8  : '), writeln(C8),
    write('  C9  : '), writeln(C9),
    nl,

    writeln('Resolution Refutation Steps:'),
    resolve(C1, C9, R1),
    write('  Resolve C1 and C9: '), writeln(R1),

    resolve(C8, R1, R2),
    write('  Resolve C8 and Resolvent 1: '), writeln(R2),

    resolve(C3, R2, R3),
    write('  Resolve C3 and Resolvent 2: '), writeln(R3),

    resolve(C7a, R3, R4),
    write('  Resolve C7a and Resolvent 3: '), writeln(R4),

    resolve(C7b, R4, R5),
    write('  Resolve C7b and Resolvent 4: '), writeln(R5),
    nl,

    write('Empty clause derived: '), writeln(R5),
    writeln('Contradiction found with negated goal.'),
    writeln('Goal proved: trusted(mira).'),
    writeln('________________________________________________________________________'),
    nl.
