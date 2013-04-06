module.exports = (grunt) ->
  grunt.initConfig
    coffee:
      src:
        files:
          'public/dist/tablestakes.js' : ['src/coffee/*.coffee']
      test:
        files:
          'public/test/test_helper.js' : 'test/test_helper.coffee'
          'public/test/unit_tests.js' : ['test/unit/*.coffee']

    sass:
      dist:
        files:
          'public/dist/tablestakes.css': 'src/scss/tablestakes.scss'

    coffeelint:
      src: ['src/coffee/*.coffee']

    docco:
      src:
        src: ['src/coffee/*.coffee']
        options:
          output: 'public/docs'

  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-sass')
  grunt.loadNpmTasks('grunt-coffeelint')
  grunt.loadNpmTasks('grunt-docco')

  grunt.registerTask('build', ['coffee:src', 'sass'])
  grunt.registerTask('test', ['coffee'])
  grunt.registerTask('default', ['coffeelint:src', 'docco', 'coffee', 'sass'])
