;;; cl-pdf copyright 2002-2003 Marc Battyani see license.txt for the details
;;; You can reach me at marc.battyani@fractalconcept.com or marc@battyani.net
;;; The homepage of cl-pdf is here: http://www.fractalconcept.com/asp/html/cl-pdf.html

(in-package pdf)

;;WARNING this part of cl-pdf is an early alpha version. Use with care!
;;Basic (and crude) text layout functions

(defun text-width (string font font-size)
  (loop for c across string
	summing (get-char-width c font font-size)))

(defun split-text (string font font-size max-width)
  (if (> (* 2 (get-char-width #\M font font-size)) max-width)
      (loop for c across string
	    collect (make-string 1 :initial-element c))
      (let ((width 0)
	    (start 0)
	    (result ()))
	(loop for i from 0
	      for c across string
	      for d = (get-char-width c font font-size) do
	      (if (or (char= c #\Newline)(char= c #\�)(> (+ width d) max-width))
		  (progn 
		    (push (string-trim '(#\Space #\Tab #\Newline #\�) (subseq string start i)) result)
		    (setf start i width 0))
		  (incf width d))
	      finally (push (string-trim '(#\Space #\Tab #\Newline #\�) (subseq string start)) result))
	(nreverse result))))

(defun draw-centered-text (x y string font font-size &optional max-width)
  (pdf:in-text-mode
   (pdf:move-text x y)
   (pdf:set-font font font-size)
   (loop with dy = (* -1.2 font-size)
	 for (str . rest) on (if max-width (split-text string font font-size max-width) (list string))
	 for last-x = 0 then offset
	 for offset = (* -0.5 (text-width str font font-size)) do
	 (move-text (- offset last-x) 0)
	 (show-text str)
	 (when rest (pdf:move-text 0 dy)))))

(defun draw-left-text (x y string font font-size &optional max-width)
  (pdf:in-text-mode
   (pdf:move-text x y)
   (pdf:set-font font font-size)
   (loop with dy = (* -1.2 font-size)
	 for (str . rest) on (if max-width (split-text string font font-size max-width) (list string))
	 for last-x = 0 then offset
	 for offset = (- (text-width str font font-size)) do
	 (move-text (- offset last-x) 0)
	 (show-text str)
	 (when rest (pdf:move-text 0 dy)))))

(defun draw-right-text (x y string font font-size &optional max-width)
  (pdf:in-text-mode
   (pdf:move-text x y)
   (pdf:set-font font font-size)
   (loop with dy = (* -1.2 font-size)
	 for (str . rest) on (if max-width (split-text string font font-size max-width) (list string))
	 do
	 (show-text str)
	 (when rest (move-text 0 dy)))))