;; Test stuff, TODO delete
(defun led-on () (digitalWrite 25 1))
(defun led-off () (digitalWrite 25 0))
(defun blink-for (amt) (progn (led-on) (delay amt) (led-off)))
(defun test-loop-1 () (loop (blink-for 200) (delay 100)))
(defun test-loop-2 () (loop (blink-for 800) (delay 400)))
(defun test-loop-3 () (loop (blink-for 500) (delay 50)))

;; FIXME not that important but should figure it out at some point
;; the first time it runs okay, but on subsequent calls it seems
;; to only blink once or twice before it crashes...
;; (only happens when passed to runOnThread)
(defun test-finite-loop () (dotimes (x 10) (blink-for 300) (delay 50)))
;; Misc Utils

;;;; Timing API

;; Vars (mostly static)
;; TODO use meter in calculations, for now assumed 4/4
(defvar meter '(4 4))
(defvar bpm 120)
(defvar bps 2)
(defvar beatDur 500)
(defvar barDur 2000)
(defvar last-reset-time (millis))  ;; holds the last time the  transport  was reset
;; Useful phasors
(defvar time 0)
(defvar t 0)
(defvar beat 0)
(defvar bar 0)
;; Update functions
(defun bpm-to-bps (bpm) (/ bpm 60))
(defun bpm-to-beatDur (bpm) (/ 1000.0 (bpm-to-bps bpm)))
(defun bpm-to-barDur (bpm) (* (bpm-to-beatDur bpm) (first meter)))

;; FIXME are these line breaks causing issues?
(defun set-bpm (new-bpm)
  (setq bpm new-bpm
        bps (bpm-to-bps new-bpm)
        beatDur (bpm-to-beatDur new-bpm)
        barDur (bpm-to-barDur new-bpm)))

;; will be called once at the beginning of every loop
(defun set-time (new-time)
  (setq time new-time
        t (- new-time last-reset-time)
        beat (/ (mod t beatDur) beatDur)
        bar (/ (mod t barDur) barDur)))

(defun update-time ()
  (set-time (millis)))

(defun reset-time ()
  (setq last-reset-time (millis))
  (set-time time))

;; UI functions
(defun mod1 (x) (mod x 1.0))

(defun fast (amt phasor)
  (mod1 (* phasor amt)))

(defun slow (amt phasor)
  (let ((result (mod (/ phasor amt) 1)))
    (if (< result 0)
        (+ 1 result)
      result)))

(defun every (amt dur)
  (/ (mod t (* amt dur)) (* amt dur)))

(defun pulse (on-relative-dur phasor &optional speed-mult)
  (let ((phasor (if speed-mult
                    (fast speed-mult phasor)
                    phasor)))
    (if (< phasor on-relative-dur) 1 0)))

(defun sqr (phasor &optional speed-mult)
  (pulse 0.5 phasor speed-mult))

;; add (cos)sine
;; add pow/log
(defun impulse (phasor &optional speed-mult)
  (pulse 0.05 phasor speed-mult))

(defun saw (phasor &optional fast-amt)
  (if fast-amt (fast fast-amt phasor) phasor))

(defun ramp (phasor &optional fast-amt)
  (saw phasor fast-amt))

(defun clamp (mn mx x) (min mx (max x mn)))
(defun clamp01 (x) (clamp 0.0 1.0 x))

(defun add (amt x) (+ amt x))
(defun sub (amt x) (- amt x))
(defun mul (amt x) (* amt x))
(defun div (amt x) (/ amt x))

(defun fromList (lst phasor)
  (let* ((num-elements (length lst))
         (scaled-phasor (* num-elements (clamp01 phasor)))
         (idx (floor scaled-phasor)))
    (if (= idx num-elements) (decf idx))
    (nth idx lst)))

;; Outputs

(defvar INPUT_1_VALUE 0)
(defvar INPUT_2_VALUE 0)

;; for testing
(defvar led-form '(sqr (fast 2 beat)))
(defun update-led () (useqDigitalWrite 99 (eval led-form)))  ;; runs on core 1
(defun led (new-form) (setq led-form new-form))  ;; runs on core 0

;; Digital outs
(defvar d1-form '(sqr beat))
(defvar d2-form '(sqr (fast 2 beat)))
(defvar d3-form '(sqr (fast 3 beat)))
(defvar d4-form '(sqr (fast 4 beat)))
(defun update-d1 () (useqDigitalWrite 1 (eval d1-form)))  ;; runs on core 1
(defun update-d2 () (useqDigitalWrite 2 (eval d2-form)))  ;; runs on core 1
(defun update-d3 () (useqDigitalWrite 3 (eval d3-form)))  ;; runs on core 1
(defun update-d4 () (useqDigitalWrite 4 (eval d4-form)))  ;; runs on core 1
(defun d1 (new-form) (setq d1-form new-form))  ;; runs on core 0
(defun d2 (new-form) (setq d2-form new-form))  ;; runs on core 0
(defun d3 (new-form) (setq d3-form new-form))  ;; runs on core 0
(defun d4 (new-form) (setq d4-form new-form))  ;; runs on core 0

;; Analog outs
(defvar a1-form '(every 2 beatDur))
(defvar a2-form '(every 4 beatDur))
(defun update-a1 () (useqAnalogWrite 1 (eval a1-form)))
(defun update-a2 () (useqAnalogWrite 2 (eval a2-form)))
(defun a1 (new-form) (setq a1-form new-form))
(defun a2 (new-form) (setq a2-form new-form))

;; TODO some kind of thread synchronisation needed here?

(defun useq-update ()
  (set-time (millis))
  (update-a1)
  (update-a2)
  (update-d1)
  (update-d2)
  (update-d3)
  (update-d4)
  (update-led))

(defun gates (lst speed)
  (mul (fromList lst (fast speed beat))
       (sqr (fast (length lst) beat))))

(defun seq (lst speed)
  (fromList lst (every speed beatDur)))

(defun sig-in (index) (useqGetInput index))
;; Convenience shortcuts
(defun in1 () (useqGetInput 1))
(defun in2 () (useqGetInput 2))

;; momentary switches 0 and 1
(defun swm (index) (useqGetInput (add 2 index)))
;; toggle switches 0 and 1
(defun swt (index) (useqGetInput (add 4 index)))
;; rotary enc switch
(defun swr () (useqGetInput 6))
;; rotary encoder value
(defun rot () (useqGetInput 7)
