;; flash once per beat:
;; `beat` is a normalised phasor,
;; which drives the `sqr` oscillator's phase
(led '(sqr (fast 1 beat)))

;; flash once per beat for the first half of the bar, then twice:
(led '(sqr (fast
            (fromList '(1 2) bar)
            beat)))

;; indexing through the `fast` parameter every 2 bars (1x bar with value 1, and another with value 4)
(led '(sqr (fast
            (fromList '(1 4) (every 2 barDur))
            beat)))

;; Using a step sequence directly
(led '(fromList '(1 0 1 1 0 0) bar))

;; Same syntax, but this allows us to use expressions inside the list, eg:
(led '(fromList
       (list 1 (sqr (fast 3 beat)))
       bar))

;; multiplying squares together is like a logical AND
(led '(*
       (sqr (fast 3 beat))
       (sqr (every 2 beatDur))))
