; Problem 2 — extended scenario.
; Adds Rock6 (soft) at SiteE and Rock7 (hard) at SiteF.
; A dust storm removes Base <-> SiteB in both directions.
; Goal: Rock1-Rock7 deposited at Base, both bays empty, rover at Base.
; Empty bays are required so every rock is delivered, not merely carried
; into Base. With this encoding, a rock at Base is not in a bay.

(define (problem mars-sample-extended)

  (:domain mars-sample-collection)

  (:objects
    curiosity - rover
    bay1 bay2 - bay
    drill1 - drill
    base site-a site-b site-c site-d site-e site-f - location
    rock1 rock2 rock3 rock4 rock5 rock6 rock7 - rock
  )

  (:init
    (at-rover curiosity base)

    (has-bay curiosity bay1)
    (has-bay curiosity bay2)
    (empty bay1)
    (empty bay2)

    (at-drill drill1 site-e)
    (at-rock rock1 site-a)
    (at-rock rock2 site-b)
    (at-rock rock3 site-c)
    (at-rock rock4 site-d)
    (at-rock rock5 site-f)
    (at-rock rock6 site-e)
    (at-rock rock7 site-f)

    (soft rock1)
    (soft rock2)
    (hard rock3)
    (soft rock4)
    (hard rock5)
    (soft rock6)
    (hard rock7)

    ; Two-way routes that remain open.
    ; Base <-> SiteB is closed by the dust storm and is intentionally omitted.
    (connected base site-a)
    (connected site-a base)

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
    (at-rock rock6 base)
    (at-rock rock7 base)
    (empty bay1)
    (empty bay2)
  ))
)
