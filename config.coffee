{path, defaultConfig} = require('showcase')

# https://github.com/brunch/brunch/blob/master/docs/config.md
exports.config = defaultConfig
  files:
    javascripts:
      joinTo:
        'assets/tablestakes.js': path('src/coffee/*')
        'assets/vendors.js':     path('vendor/js/jquery.js', 'vendor/js/underscore.js', 'vendor/js/backbone.js', 'vendor/rainbow/*'
                                      'vendor/js/d3.js', 'vendor/js/bootstrap.js', 'vendor/js/coffee-script.js', 'vendor/js/jquery-ui.js')
        'assets/examples.js':    path('src/examples/*')
        'tests/unit_tests.js':   path('test/unit/*')
        'tests/vendors.js':      path('vendor/test/chai.js', 'vendor/test/mocha.js')
        'tests/blanket.js':      path('vendor/test/blanket.js')
      order:
        before: ['vendor/js/jquery.js', 'vendor/js/underscore.js', 'vendor/rainbow/rainbow.js']

    stylesheets:
      joinTo:
        'assets/vendors.css':     path('vendor/css/bootstrap.css', 'vendor/css/jquery-ui.css', 'vendor/rainbow/theme.css')
        'assets/tablestakes.css': path('src/scss/*')
        'tests/vendors.css':      path('vendor/test/mocha.css')
      order:
        before: ['vendor/css/bootstrap.css']
