;; swm-freebsd-net-modeline.lisp
;;
;; Put %n in your modeline format string to show information about network
;; interfaces.
;;

(in-package #:swm-freebsd-net-modeline)

(defvar *interface* "")
(defvar *down* "0")
(defvar *net-stream* nil)
(defvar *up* "0")

(defun set-net-stream ()
  (setf *net-stream*
	(sb-ext:process-output
	 (sb-ext:run-program "ml_net.sh" nil
			     :output :stream
			     :search t
			     :wait nil))))

(defun fmt-freebsd-net-modeline-interface (ml)
  "Return the name of the interface associated with the default route.  Also do
all the work for the other formatters in this module."
  (declare (ignore ml))
  (when (not *net-stream*)
    (set-net-stream))
  (when (listen *net-stream*)
    (let ((net-info (stumpwm::split-string
		     (read-line *net-stream* nil "") "	")))
      (setf *interface* (car net-info))
      (setf *up* (nth 1 net-info))
      (setf *down* (nth 2 net-info))))
  (format nil "~a" *interface*))

(defun fmt-freebsd-net-modeline-down (ml)
  "Return download rate in KB/s for the interface associated with the default
route."
  (declare (ignore ml))
  ;; (when (or (not (boundp '*down*)) (cl-ppcre::scan "^[^0-9]+" *down*))
  ;;   (setf *down* "0"))
  (format nil "~8,2f" *down*))

(defun fmt-freebsd-net-modeline-up (ml)
  "Return upload rate in KB/s for the interface associated with the default
route."
  (declare (ignore ml))
  ;; (when (or (not (boundp '*up*)) (cl-ppcre::scan "^[^0-9]+" *up*))
  ;;   (setf *up* "0"))
  (format nil "~8,2f" *up*))

;; Install formatter
(stumpwm::add-screen-mode-line-formatter #\I #'fmt-freebsd-net-modeline-interface)
(stumpwm::add-screen-mode-line-formatter #\U #'fmt-freebsd-net-modeline-up)
(stumpwm::add-screen-mode-line-formatter #\D #'fmt-freebsd-net-modeline-down)
