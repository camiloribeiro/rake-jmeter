rake-jmeter
===========

Tasks to handle JMeter test execution

It's a very simple, very rough automation framework using JMeter. Right now, it:

* Rsyncs the test scripts and test configurations in your local with 4 stress
machines, called stress0x

* Launches the JMeter master and 4 slaves in the stress machines remotely.

* After the tests are finished, pulls the JTL logs automatically.

* After pulling the JTL logs, creates the result graphs automatically.

Why does it do it?
----

Because it saves a lot of time.  Because it might be a good starting point for
the teams that will use JMeter in the future.  Because it is cool to do all
these stuff:)

Ok, I got it. Is there any catch?
---

As always:) You need to be careful when runing tests: right now, it just kills
the JMeter instances in the stress machines for a clean run.

The code is crap. It mixes up all sorts of concerns and there are hacks in every
file you look at. It'll need a lot of refactoring, but ideally this will evolve
into a DSL-looking thing that will wrap JMeter in such a way that once the JMX
files are put in plans/, everything else is obvious.
