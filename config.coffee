path = require('showcase').path

# https://github.com/brunch/brunch/blob/master/docs/config.md
exports.config =
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
        'assets/vendors.css': path('vendor/css/bootstrap.css')
        'assets/tablestakes.css' : path('src/scss/*')

  paths:
    app: 'src'

  plugins:
    sass:
      debug: 'comments'

  modules:
    definition: false
    # module wrapper
    wrapper: (path, data) ->
      if path.match(/\.(coffee|hbs)$/)
        data = """
        (function() {
          #{data}
        }).call(this);
        """
      data + '\n\n'