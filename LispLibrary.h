const char LispLibrary[] PROGMEM = "(defun useq-update ()\n"
                                   "  (if (> (mod (millis) 200)\n"
                                   "         100)\n"
                                   "      (c_digitalWrite 99 1)\n"
                                   "      (c_digitalWrite 99 0)))\n";
