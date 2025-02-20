const char LispLibrary[] PROGMEM =
"\n"
"(defun led-on () (digitalWrite 25 1))\n"
"(defun led-off () (digitalWrite 25 0))\n"
"(defun blink-for (amt) (progn (led-on) (delay amt) (led-off)))\n"
"(defun test-loop-1 () (loop (blink-for 200) (delay 100)))\n"
"(defun test-loop-2 () (loop (blink-for 800) (delay 400)))\n"
"(defun test-loop-3 () (loop (blink-for 500) (delay 50)))\n"
"\n"
"\n"
"\n"
"\n"
"\n"
"(defun test-finite-loop () (dotimes (x 10) (blink-for 300) (delay 50)))\n"
"\n"
"\n"
"\n"
"\n"
"\n"
"\n"
"(defvar meter '(4 4))\n"
"(defvar bpm 120)\n"
"(defvar bps 2)\n"
"(defvar beatDur 500)\n"
"(defvar barDur 2000)\n"
"(defvar last-reset-time (millis))  \n"
"\n"
"(defvar time 0)\n"
"(defvar t 0)\n"
"(defvar beat 0)\n"
"(defvar bar 0)\n"
"\n"
"(defun bpm-to-bps (bpm) (/ bpm 60))\n"
"(defun bpm-to-beatDur (bpm) (/ 1000.0 (bpm-to-bps bpm)))\n"
"(defun bpm-to-barDur (bpm) (* (bpm-to-beatDur bpm) (first meter)))\n"
"\n"
"\n"
"(defun set-bpm (new-bpm)\n"
"  (setq bpm new-bpm\n"
"        bps (bpm-to-bps new-bpm)\n"
"        beatDur (bpm-to-beatDur new-bpm)\n"
"        barDur (bpm-to-barDur new-bpm)))\n"
"\n"
"\n"
"(defun set-time (new-time)\n"
"  (setq time new-time\n"
"        t (- new-time last-reset-time)\n"
"        beat (/ (mod t beatDur) beatDur)\n"
"        bar (/ (mod t barDur) barDur)))\n"
"\n"
"(defun update-time ()\n"
"  (set-time (millis)))\n"
"\n"
"(defun reset-time ()\n"
"  (setq last-reset-time (millis))\n"
"  (set-time time))\n"
"\n"
"(defun mod1 (x) (mod x 1.0))\n"
"\n"
"(defun fast (amt phasor) (mod1 (* phasor amt)))\n"
"\n"
"(defun pulse (on-relative-dur phasor &optional speed-mult)\n"
"  (let ((phasor (if speed-mult\n"
"                    (fast speed-mult phasor)\n"
"                    phasor)))\n"
"    (if (< phasor on-relative-dur) 1 0)))\n"
"\n"
"(defun sqr (phasor &optional speed-mult)\n"
"  (pulse 0.5 phasor speed-mult))\n"
"\n"
"\n"
"\n"
"(defun impulse (phasor &optional speed-mult)\n"
"  (pulse 0.05 phasor speed-mult))\n"
"\n"
"(defun saw (phasor &optional fast-amt)\n"
"  (if fast-amt (fast fast-amt phasor) phasor))\n"
"\n"
"(defun ramp (phasor &optional fast-amt)\n"
"  (saw phasor fast-amt))\n"
"\n"
"(defun clamp (mn mx x) (min mx (max x mn)))\n"
"(defun clamp01 (x) (clamp 0.0 1.0 x))\n"
"\n"
"(defun add (amt x) (+ amt x))\n"
"(defun sub (amt x) (- amt x))\n"
"(defun mul (amt x) (* amt x))\n"
"(defun div (amt x) (/ amt x))\n"
"\n"
"(defun fromList (lst phasor)\n"
"  (let* ((num-elements (length lst))\n"
"         (scaled-phasor (* num-elements (clamp01 phasor)))\n"
"         (idx (floor scaled-phasor)))\n"
"    (if (= idx num-elements) (decf idx))\n"
"    (nth idx lst)))\n"
"\n"
"\n"
"\n"
"(defvar INPUT_1_VALUE 0)\n"
"(defvar INPUT_2_VALUE 0)\n"
"\n"
"\n"
"(defvar led-form '(sqr beat))\n"
"(defun update-led () (c_digitalWrite 99 (eval led-form)))  \n"
"(defun led (new-form) (setq led-form new-form))  \n"
"\n"
"\n"
"(defvar d1-form '(sqr beat))\n"
"(defvar d2-form '(sqr (fast 2 beat)))\n"
"(defvar d3-form '(sqr (fast 3 beat)))\n"
"(defvar d4-form '(sqr (fast 4 beat)))\n"
"(defun update-d1 () (c_digitalWrite 1 (eval d1-form)))  \n"
"(defun update-d2 () (c_digitalWrite 2 (eval d2-form)))  \n"
"(defun update-d3 () (c_digitalWrite 3 (eval d3-form)))  \n"
"(defun update-d4 () (c_digitalWrite 4 (eval d4-form)))  \n"
"(defun d1 (new-form) (setq d1-form new-form))  \n"
"(defun d2 (new-form) (setq d2-form new-form))  \n"
"(defun d3 (new-form) (setq d3-form new-form))  \n"
"(defun d4 (new-form) (setq d4-form new-form))  \n"
"\n"
"\n"
"(defun update-a1 () (c_analogWrite 1 (eval a1-form)))  \n"
"(defun update-a2 () (c_analogWrite 2 (eval a2-form)))  \n"
"\n"
"\n"
"(defun in1 (new-form) INPUT_1_VALUE)\n"
"(defun in2 (new-form) (setq d4-form new-form))  \n"
"\n"
"\n"
"(defun useq_update ()\n"
"  (set-time (millis))\n"
"  (update-led))\n" ;
