# Helper for easy generation valid brunch regexps
path = (paths...) ->
  escapedFiles = paths.map((pattern) ->
    pattern.replace(/[\-\[\]\/\{\}\(\)\+\?\.\\\^\$\|]/g, "\\$&")
  ).join('|')
  new RegExp('^' + escapedFiles)

# https://github.com/brunch/brunch/blob/master/docs/config.md
exports.config =
  files:
    javascripts:
      joinTo:
        'assets/tablestakes.js': path('src/coffee/*')
        'assets/examples.js': path('src/examples/*')
        'assets/vendors.js': path('vendor/js/jquery.js', 'vendor/js/underscore.js', 'vendor/js/backbone.js', 'vendor/js/d3.js')
        'assets/unit_tests.js': path('vendor/test/chai.js', 'test/unit/*', 'test/test_helper.coffee')
      order:
        before: ['vendor/js/jquery.js', 'vendor/js/underscore.js']

    stylesheets:
      joinTo:
        'assets/vendors.css': path('vendor/css/bootstrap.css')
        'assets/tablestakes.css' : path('src/scss/*')

  modules:
    wrapper: false
    definition: false

  paths:
    app: 'src'

  plugins:
    sass:
      debug: 'comments'
