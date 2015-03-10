# `swm-freebsd-net-modeline`

Put %I, %U, and %D in your StumpWM mode-line format string
(*screen-mode-line-format*) to show the network interface associated with the
default route and the current upload and download transfer rates (in KiB/s) for
that interface.

In addition to the lisp code, there is a small C program, now.c and Bourne shell
script, ml_net.sh.  Compile now.c
```shell
	clang now.c -o now
	```
and put the compiled binary in your $PATH.  Make sure the shell script is
executable by the user running StumpWM and also within the user's $PATH.  Have a
look at the script to customize certain settings, such as the interval between
updates.  At the top of the script there is a variable, net_cmd, that holds a
sysctl command.  You may need to tweek this command, so that it returns the
interface name and a count of the bytes received and transmitted.

FAQ

Q: What do I need to put in my ~/.stumpwmrc to get this working?

A: First, make sure the source is in your load-path.  To add it, use something
like
```lisp
    (add-to-load-path "/usr/home/jrm/scm/swm-freebsd-net-modeline")
```
Next, load the module with
```lisp
    (load-module "swm-freebsd-net-modeline")
```
Finally create a mode-line format string with %I, %U, and %D in it, e.g.,
```lisp
    (setf *screen-mode-line-format* "^[^8*%I^] %U^[^9*KiB/s^] %D^[^9*KiB/s^]"
```

Q: So, why use a separate script?  Couldn't all the code be contained within the
module?

A: Yes, it could.  I tried doing that with and without threads.  I found StumpWM
became less responsive in both cases.  Don't you prefer a snappy StumpWM?

Q: Will this only run on FreeBSD?

A: By default, yes, but it should be quite simple to modify ml_mem.sh to get it
working on your OS.