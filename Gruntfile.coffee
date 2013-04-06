module.exports = (grunt) ->
  grunt.initConfig
    coffee:
      src:
        files:
          'public/assets/tablestakes.js' : ['src/coffee/*.coffee']

    sass:
      dist:
        files:
          'public/assets/tablestakes.css': 'src/scss/tablestakes.scss'

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

  grunt.registerTask('build', ['coffee', 'sass'])
  grunt.registerTask('default', ['coffeelint:src', 'docco', 'coffee' 'sass'])
