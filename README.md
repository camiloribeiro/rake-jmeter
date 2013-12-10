Rake-JMeter ლ(ಠ_ಠლ)
===========

Tasks to handle JMeter test execution

It's a very simple, very rough automation framework using JMeter. Right now, it:

* Rsyncs the test scripts and test configurations in your local with 4 stress
machines, called stress0x

* Launches the JMeter master and 4 slaves in the stress machines remotely.

* After the tests are finished, pulls the JTL logs automatically.

* After pulling the JTL logs, creates the result graphs automatically.

* Run a set of assertions such as avg responsetime, std deviation and thresholds based on acceptance criteria.

Why does it do it?
----

Because it saves a lot of time.  Because it might be a good starting point for
the teams that will use JMeter in the future.  Because it is cool to do all
these stuff:)

Running a Demo
---------

You need Java1.6++, ruby 1.9.3++ and virtual box (Vagrant)

    $ git clone git@github.com:camiloribeiro/rake-jmeter.git
    $ sh bootstrap

It's going to set up the whole environment run a JMeter dumb test in two virtual machines and show you the report.
You can reuse the environment to play with Rake-JMeter and understand its engine whithout buy cloud service or set up a virtual environment manually.

if you want to see it really working, besides the jmeter dumb test, you can use the app I built for this, called hitz:

    https://github.com/camiloribeiro/hitz

There is an special rake task to run it. After start the app in your local, change the host plan/hitz.jmx to your IP Address and run:

    $ rake perf:hitz:nominal

It's a meteor app, so you can see the two different nodes running against Hitz at the same time. Enjoy.

Usage
----

You need Java1.6++ and ruby 1.9.3++

    $ git clone git@github.com:camiloribeiro/rake-jmeter.git
    $ bundle install

Set your enviroment editing the file (instructions inside):

    $ vim config/env_config.rb

Copy and edit the new files to your configurations, instructions inside:

    $ cp plans/sample.jmx plans/<your_plan>.jmx
    $ cp schedule/sample_nominal.properties schedule/<your_plan>_nominal.properties
    $ cp config/sample_nominal_acc.rb config/<your_plan>_nominal_acc.rb
    $ vim plans/<your_plan>.jmx schedule/<your_plan>_nominal.properties config/<your_plan>_nominal_acc.rb

Running
 
    $ rake perf:<your_plan>:nominal

I recomend run the demo first, understand how it works and create a "dual" test, with two minutes before start your load tests

What's next?
---

As always:) You need to be careful when runing tests: right now, it just kills
the JMeter instances in the stress machines for a clean run.

The code is crap. It mixes up all sorts of concerns and there are hacks in every
file you look at. It'll need a lot of refactoring, but ideally this will evolve
into a DSL-looking thing that will wrap JMeter in such a way that once the JMX
files are put in plans/, everything else is obvious.

The next great improvement will be the automatic creation of the test plan and its configurations.

LICENSE
=======

Copyright 2013 Camilo Ribeiro cribeiro@thoughtworks.com and Carlos Villela cv@thoughtworks.com

This file is part of Rake-JMeter.

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/camiloribeiro/rake-jmeter/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

