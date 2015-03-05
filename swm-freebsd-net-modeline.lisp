;; swm-freebsd-net-modeline.lisp
;;
;; Put %n in your modeline format string to show information about network
;; interfaces.
;;

(in-package #:swm-freebsd-net-modeline)

(defvar *last-rx* nil)
(defvar *last-tx* nil)
(defvar *rx-rate* nil)
(defvar *tx-rate* nil)
(defvar *interface* nil)
(defvar *prev-time-interface* 0)
(defvar *prev-time-up* 0)
(defvar *prev-time-down* 0)

(defun get-default-route-interface ()
  "Return the name of the interface associated with the default route."

  (string-trim
   '(#\Space #\Tab #\Newline)
   (stumpwm::run-prog-collect-output
    stumpwm::*shell-program* "-c"
    "/usr/bin/netstat -r -4 | awk '/^default/ {print $4}'")))

(defun fmt-freebsd-net-modeline-interface (ml)
  "Display the name of the interface associated with the default route in the
modeline."
  (declare (ignore ml))
  (let ((now (/ (get-internal-real-time) internal-time-units-per-second)))
    (when (or (= 0 *prev-time-interface*) (>= (- now *prev-time-interface*) 30))
      (setf *prev-time-interface* now)
      (sb-thread:make-thread
       (lambda ()
	 (setf *interface* (get-default-route-interface)))
       :name "default-route-interface-thread")))
  (format nil "~a" *interface*))

(defun fmt-freebsd-net-modeline-down (ml)
  "Return download rate in KB/s for the interface associated with the default
route."
  (declare (ignore ml))
  (let ((now (/ (get-internal-real-time) internal-time-units-per-second)))
    (when (or (= 0 *prev-time-down*) (>= (- now *prev-time-down*) 5))
      (sb-thread:make-thread
       (lambda ()
	 (let* ((interface (cl-ppcre::regex-replace
			    "(\\d+)" (get-default-route-interface) ".\\1"))
		(rx (parse-integer
		     (string-trim
		      '(#\Space #\Tab #\Newline)
		      (stumpwm::run-prog-collect-output
		       "/sbin/sysctl" "-n"
		       (concatenate 'string "dev." interface
				    ".mac_stats.good_octets_recvd"))))))
	   (if *last-rx*
	       (setf *rx-rate* (* 0.0009765625 (/ (- rx *last-rx*)
						  (- now *prev-time-down*)))))
	   (setf *prev-time-down* now)
	   (setf *last-rx* rx)))) :name "down-rate-thread"))
  (format nil "~8,2f" *rx-rate*))

(defun fmt-freebsd-net-modeline-up (ml)
  "Return upload rate in KB/s for the interface associated with the default
route."
  (declare (ignore ml))
  (let ((now (/ (get-internal-real-time) internal-time-units-per-second)))
    (when (or (= 0 *prev-time-up*) (>= (- now *prev-time-up*) 5))
      (sb-thread:make-thread
       (lambda ()
	 (let* ((interface (cl-ppcre::regex-replace
			    "(\\d+)" (get-default-route-interface) ".\\1"))
		(tx (parse-integer
		     (string-trim
		      '(#\Space #\Tab #\Newline)
		      (stumpwm::run-prog-collect-output
		       "/sbin/sysctl" "-n"
		       (concatenate 'string "dev." interface
				    ".mac_stats.good_octets_txd"))))))
	   (if *last-tx*
	       (setf *tx-rate* (* 0.0009765625 (/ (- tx *last-tx*)
						  (- now *prev-time-up*)))))
	   (setf *prev-time-up* now)
	   (setf *last-tx* tx)))) :name "up-rate-thread"))
  (format nil "~8,2f" *tx-rate*))

;; Install formatter
(stumpwm::add-screen-mode-line-formatter #\n #'fmt-freebsd-net-modeline-interface)
(stumpwm::add-screen-mode-line-formatter #\o #'fmt-freebsd-net-modeline-up)
(stumpwm::add-screen-mode-line-formatter #\i #'fmt-freebsd-net-modeline-down)
