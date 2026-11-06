; Problem 2 — base scenario.
; Five rocks, drill at SiteE, both bays empty, rover at Base.
; Goal: every rock deposited at Base, both bays empty, rover at Base.

(define (problem mars-sample-base)

  (:domain mars-sample-collection)

  (:objects
    curiosity - rover
    bay1 bay2 - bay
    drill1 - drill
    base site-a site-b site-c site-d site-e site-f - location
    rock1 rock2 rock3 rock4 rock5 - rock
  )

  (:init
    ; Rover starts at Base, not carrying the drill (closed world: no carrying-drill fact).
    (at-rover curiosity base)

    ; Curiosity has two storage bays, both empty.
    (has-bay curiosity bay1)
    (has-bay curiosity bay2)
    (empty bay1)
    (empty bay2)

    ; Equipment and samples.
    (at-drill drill1 site-e)
    (at-rock rock1 site-a)
    (at-rock rock2 site-b)
    (at-rock rock3 site-c)
    (at-rock rock4 site-d)
    (at-rock rock5 site-f)

    (soft rock1)
    (soft rock2)
    (hard rock3)
    (soft rock4)
    (hard rock5)

    ; Two-way routes (each direction is a separate fact).
    (connected base site-a)
    (connected site-a base)

    (connected base site-b)
    (connected site-b base)

    (connected site-a site-c)
    (connected site-c site-a)

    (connected site-b site-d)
    (connected site-d site-b)

    (connected site-c site-e)
    (connected site-e site-c)

    (connected site-d site-e)
    (connected site-e site-d)

    (connected site-e site-f)
    (connected site-f site-e)

    ; One-way steep slope. There is no (connected site-d site-c).
    (connected site-c site-d)
  )

  (:goal (and
    (at-rover curiosity base)
    (at-rock rock1 base)
    (at-rock rock2 base)
    (at-rock rock3 base)
    (at-rock rock4 base)
    (at-rock rock5 base)
    (empty bay1)
    (empty bay2)
  ))
)
