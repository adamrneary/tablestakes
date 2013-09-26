module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")

#    "gh-pages":
#      options:
#        base: "#{__dirname}/ghpages"
#        branch: "gh-pages"
#        repo: "git@github.com:Aluman/TestGrunt.git"
#      ghp:
#        disabled: no
#        src: ["**/*"]

    "gh-pages":
      options:
        base: "#{__dirname}/ghpages"
        branch: "gh-pages"
        repo: "git@github.com:activecell/tablestakes.git"
      ghp:
        disabled: no
        src: ["**/*"]

    docco:
      options:
        layout : "parallel"
        output : "ghpages/docs/"
        timeout: 1000
      docs:
        disabled: no
        src: "src/coffee/**/*.coffee"

    coffee:
      options:
        disable: no
      compileJoined:
        options:

          join: true
        files:
          "ghpages/assets/tablestakes.js": "src/coffee/*.coffee"
          "ghpages/assets/examples.js"   : "src/examples/*.coffee"
          "ghpages/assets/unit_tests.js" : "test/unit/*.coffee"

    compass:
      compileJoined:
        options:
          sassDir: 'src/scss'
          cssDir: 'ghpages/assets/'

    clean: [
      "ghpages/assets/colors.css"
      "ghpages/assets/mixins.css"
    ]

    watch:
      coffee:
        files: [
          "src/coffee/**/*.coffee"
          "src/examples/**/*.coffee"
          "test/unit/**/*.coffee"
        ]
        tasks: ["coffee"]

      compass:
        files: ["src/scss"]
        tasks: ["compass"]

    styleguide:
      options:
        markdown: false
        base: "#{__dirname}/"
        name: "styleguide"

      files:
        templatepath: "views/examples/"
        scsssrc: "src/scss/"
        srcname: "tablestakes.scss"
        sections: "views/sections/"
        dstpath: "ghpages/"

    grunt.registerTask "compile-css", [
      "compass"
      "clean"
    ]

    grunt.registerTask "compile-assets", [
      "coffee"
      "compile-css"
    ]

    grunt.registerTask "compile-docs", [
      "docco"
    ]

    grunt.registerTask "compile-styleguide", [
      "styleguide"
    ]


    grunt.registerTask "default", [
      "compile-assets"
      "compile-docs"
#      "copy"
      "compile-styleguide"
#      "gh-pages"
      "watch"
    ]

    grunt.loadNpmTasks "showcase"