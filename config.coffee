# https://github.com/brunch/brunch/blob/master/docs/config.md
exports.config =
  modules:
    wrapper: false
    definition: false

  paths:
    app: 'src'

  files:
    javascripts:
      joinTo:
        'dist/tablestakes.js': /^src\/coffee/
        '../tmp/unit_tests.js': /^test\/(unit|test\_helper)/

    stylesheets:
      joinTo:
        'dist/tablestakes.css' : /^src\/scss/
