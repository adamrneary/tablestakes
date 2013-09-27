module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")

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
        output : "ghpages/annotated_sources/"
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

    sass:
      tablestakes:
        options:
          style: 'expanded'
        files:
          'ghpages/assets/tablestakes.css': 'src/scss/tablestakes.scss'

    clean:
#      sass: [
#        "ghpages/assets/colors.css"
#        "ghpages/assets/mixins.css"
#      ]
      afterpush:[
        "ghpages"
      ]

    copy:
      examples:
        files: [
          expand: true, cwd: "src/examples/list/", src: ["*.coffee"], dest: "ghpages/examples/"
        ]
      docs:
        files: [
          expand: true, cwd: "docs/", src: ["**"], dest: "ghpages/docs/"
        ]
      testrunner:
        files: [
          expand: true, cwd: "test/", src: ["test_runner.html"], dest: "ghpages/"
        ]

    watch:
      coffee:
        files: [
          "src/coffee/**/*.coffee"
          "src/examples/**/*.coffee"
          "test/unit/**/*.coffee"
        ]
        tasks: ["coffee"]

      sass:
        files: ["src/scss"]
        tasks: ["sass"]

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

    symlink:
      fonts:
        src: 'node_modules/showcase/vendor/fonts/'
        dest: 'ghpages/fonts'
      images:
        src: 'node_modules/showcase/vendor/images/'
        dest: 'ghpages/images'
      vendor:
        src: 'node_modules/showcase/vendor/'
        dest: 'ghpages/vendor'

    "compile-handlebars":
      index:
        template: "views/layout.hbs"
        templateData: {body: "EmptyPage"}
        output: "ghpages/index.html"
      home:
        template: "{{{datablock}}}"
        templateData: {datablock: "EmptyPage"}
        output: "ghpages/home.html"
      demo:
        template: "views/examples/index.hbs"
        templateData: {demoblock: "<script src='assets/examples.js' defer></script>"}
        output: "ghpages/demo.html"
      performance:
        template: "{{{empty}}}"
        templateData: {empty: ""}
        output: "ghpages/performance.html"

    grunt.registerTask "compile-css", [
      "sass"
#      "clean:compass"
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
      "copy"
      "symlink"
      "compile-handlebars"
      "compile-styleguide"
#      "gh-pages"
#      "clean:afterpush"
#      "watch"
    ]

    grunt.loadNpmTasks "showcase"
