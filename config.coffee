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
        'dist/tablestakes.js': path('src/coffee/*')
        '../tmp/unit_tests.js': path('test/unit/*', 'test/test_helper.coffee')

    stylesheets:
      joinTo:
        'dist/tablestakes.css' : path('src/scss/*')

  modules:
    wrapper: false
    definition: false

  paths:
    app: 'src'

  plugins:
    sass:
      debug: 'comments'
