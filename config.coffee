{path, defaultConfig} = require('showcase')

# https://github.com/brunch/brunch/blob/master/docs/config.md
exports.config = defaultConfig
  files:
    javascripts:
      joinTo:
        'assets/tablestakes.js': path('src/coffee/*')
        'assets/examples.js':    path('src/examples/*')
        'assets/vendors.js':     path('vendor/js/jquery.js', 'vendor/js/underscore.js', 'vendor/js/backbone.js',
                                      'vendor/js/d3.js', 'vendor/js/bootstrap.js', 'vendor/rainbow/*')
        'assets/unit_tests.js':  path('vendor/test/chai.js', 'test/unit/*', 'test/test_helper.coffee')
      order:
        before: ['vendor/js/jquery.js', 'vendor/js/underscore.js', 'vendor/rainbow/rainbow.js']

    stylesheets:
      joinTo:
        'assets/vendors.css':     path('vendor/css/bootstrap.css')
        'assets/tablestakes.css': path('src/scss/*')
