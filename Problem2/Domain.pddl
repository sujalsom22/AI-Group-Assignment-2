; Problem 2 — Sample Collection Planning using PDDL
; Domain uses only :strips and :typing.
; No numeric fluents, no negative preconditions, no conditional effects.
;
; The drill is not stored in a bay. Once picked up it stays with the rover
; (carrying-drill is never deleted). Each bay holds at most one rock, encoded
; by the positive fluent (empty ?bay), which is deleted on collect and added
; on deposit. Hard and soft rocks are distinguished by positive predicates so
; that collect-hard can require the drill without a negative precondition.

(define (domain mars-sample-collection)

  (:requirements :strips :typing)

  (:types
    location rover bay drill rock - object
  )

  (:predicates
    (at-rover ?r - rover ?l - location)
    (at-rock ?rk - rock ?l - location)
    (at-drill ?d - drill ?l - location)
    (connected ?from - location ?to - location)
    (has-bay ?r - rover ?b - bay)
    (empty ?b - bay)
    (stored ?b - bay ?rk - rock)
    (carrying-drill ?r - rover ?d - drill)
    (soft ?rk - rock)
    (hard ?rk - rock)
  )

  ; Move along one directed link. Two-way routes are two connected facts.
  ; The steep slope SiteC -> SiteD is a single connected fact in the problem.
  (:action move
    :parameters (?r - rover ?from - location ?to - location)
    :precondition (and
      (at-rover ?r ?from)
      (connected ?from ?to)
    )
    :effect (and
      (not (at-rover ?r ?from))
      (at-rover ?r ?to)
    )
  )

  ; Pick up the drill at the rover's current location. It is kept for the
  ; rest of the mission, so there is no drop-drill action.
  (:action pick-drill
    :parameters (?r - rover ?d - drill ?l - location)
    :precondition (and
      (at-rover ?r ?l)
      (at-drill ?d ?l)
    )
    :effect (and
      (not (at-drill ?d ?l))
      (carrying-drill ?r ?d)
    )
  )

  ; Soft rocks can be collected directly into an empty bay.
  (:action collect-soft
    :parameters (?r - rover ?rk - rock ?b - bay ?l - location)
    :precondition (and
      (at-rover ?r ?l)
      (at-rock ?rk ?l)
      (has-bay ?r ?b)
      (empty ?b)
      (soft ?rk)
    )
    :effect (and
      (not (at-rock ?rk ?l))
      (not (empty ?b))
      (stored ?b ?rk)
    )
  )

  ; Hard rocks can be collected only while the rover is carrying the drill.
  (:action collect-hard
    :parameters (?r - rover ?rk - rock ?b - bay ?l - location ?d - drill)
    :precondition (and
      (at-rover ?r ?l)
      (at-rock ?rk ?l)
      (has-bay ?r ?b)
      (empty ?b)
      (hard ?rk)
      (carrying-drill ?r ?d)
    )
    :effect (and
      (not (at-rock ?rk ?l))
      (not (empty ?b))
      (stored ?b ?rk)
    )
  )

  ; Deposit the rock in a bay at the rover's current location and free the bay.
  (:action deposit
    :parameters (?r - rover ?rk - rock ?b - bay ?l - location)
    :precondition (and
      (at-rover ?r ?l)
      (has-bay ?r ?b)
      (stored ?b ?rk)
    )
    :effect (and
      (not (stored ?b ?rk))
      (empty ?b)
      (at-rock ?rk ?l)
    )
  )
)
