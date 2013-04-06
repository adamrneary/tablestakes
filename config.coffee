{path, defaultConfig} = require('showcase')

# https://github.com/brunch/brunch/blob/master/docs/config.md
exports.config = defaultConfig
  files:
    javascripts:
      joinTo:
        'assets/tablestakes.js': path('src/coffee/*')
        'assets/vendors.js':     path('vendor/js/jquery.js', 'vendor/js/underscore.js', 'vendor/js/backbone.js', 'vendor/rainbow/*'
                                      'vendor/js/d3.js', 'vendor/js/bootstrap.js', 'vendor/js/coffee-script.js', 'vendor/js/jquery-ui.js')
        'assets/unit_tests.js':  path('vendor/test/chai.js', 'test/unit/*', 'test/test_helper.coffee')
        'assets/examples_index.js':       path('src/examples/index.coffee')
        'assets/examples_performance.js': path('src/examples/index.coffee')
      order:
        before: ['vendor/js/jquery.js', 'vendor/js/underscore.js', 'vendor/rainbow/rainbow.js']

    stylesheets:
      joinTo:
        'assets/vendors.css':     path('vendor/css/bootstrap.css', 'vendor/css/jquery-ui.css', 'vendor/rainbow/theme.css')
        'assets/tablestakes.css': path('src/scss/*')
      order:
        before: ['vendor/css/bootstrap.css']
