;;;; swm-freebsd-net-modeline.asd

(asdf:defsystem #:swm-freebsd-net-modeline
  :description "Show information about network interfaces in the StumpWM modeline"
  :author "Joseph Mingrone <jrm@ftfl.ca>"
  :license "2-CLAUSE BSD (see COPYRIGHT file for details)"
  :depends-on (#:stumpwm)
  :serial t
  :components ((:file "package")
               (:file "swm-freebsd-net-modeline")))

