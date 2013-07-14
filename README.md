# Tablestakes
Bad-ass interactive tables.

## Installation

    $ bower install git@github.com:activecell/tablestakes.git#x.x.x --save

## The five-minute setup.
Check your system for local requirements (run until it passes!):

    script/bootstrap

Run tests to ensure that all pass:

    npm test

Run the project locally (with tests and watcher):

    npm start

Then navigate to the [showcase](http://localhost:5000).

### Hacking on the source
* Source for the library is in src/coffee/
* Tests for the library are in test/
* Run `testem` in order to run web-server for unit tests
* ~ Showcase files are in examples/public/coffee/

All source code should be documented with [docco](http://jashkenas.github.com/docco/).

### Hacking on design

* Source for our stylesheet is in src/scss/
* ~ Templates for the styleguide sections are in [handlebars](http://jade-lang.com/) format in examples/views/sections/

All design should be documented with [kss](https://github.com/kneath/kss) and showcased in our style guide. Simply ensure that you have a valid section commented in the source and a corresponding template available.
