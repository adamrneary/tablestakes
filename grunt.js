/*global module:false*/
module.exports = function(grunt) {
  grunt.loadNpmTasks('grunt-coffee'); // http://github.com/avalade/grunt-coffee
  grunt.loadNpmTasks('grunt-compass'); // https://github.com/sindresorhus/grunt-sass
  grunt.loadNpmTasks('grunt-styleguide'); // https://github.com/indieisaconcept/grunt-styleguide
  grunt.loadNpmTasks('grunt-contrib-copy'); // https://github.com/gruntjs/grunt-contrib-copy
  // Project configuration.
  grunt.initConfig({
    pkg: '<json:package.json>',
    meta: {
      banner: '/*! <%= pkg.title || pkg.name %> - v<%= pkg.version %> - ' +
        '<%= grunt.template.today("yyyy-mm-dd") %>\n' +
        '<%= pkg.homepage ? "* " + pkg.homepage + "\n" : "" %>' +
        '* Copyright (c) <%= grunt.template.today("yyyy") %> <%= pkg.author.name %>;' +
        ' Licensed <%= _.pluck(pkg.licenses, "type").join(", ") %> */'
    },
    coffee:{
        coffee:{
            src: ['src/js/models/*','src/js/util/*'],
            dest: 'build/'
        }       
    },
    compass:{
        dev:{
            src: 'src/scss',
            specify: 'src/scss/tables.scss',
            dest: 'dist'            
      }  
    },
    styleguide: {
      dev:{
        files: {
        'examples/styleguide': 'src/scss/tables.scss'
        }
      }
    },
    copy:{
        dist:{
            files:{
                "examples/js/":"dist/tablestakes.js",
                "examples/css/":"dist/tables.css",
                "dist/":"src/scss/tables.scss"
            }
        }        
    },
    concat: {
        dist: {
            src: ['<banner:meta.banner>', 
                  'src/js/intro.js',
                  'src/js/core.js',
                  'build/table.js',
                  'src/js/outro.js'],
            dest: 'dist/<%= pkg.name %>.js'
        }
    },
    min: {
      dist: {
        src: ['<banner:meta.banner>', '<config:concat.dist.dest>'],
        dest: 'dist/<%= pkg.name %>.min.js'
      }
    },
    watch: {
      files: '<config:lint.files>',
      tasks: 'build'
    },
    jshint: {
      options: {
        curly: true,
        eqeqeq: true,
        immed: true,
        latedef: true,
        newcap: true,
        noarg: true,
        sub: true,
        undef: true,
        boss: true,
        eqnull: true,
        browser: true
      },
      globals: {}
    },
    uglify: {},
    lint:{
        files: ["src/**/*"]
    }
  });

  // Default task.
  grunt.registerTask('default', 'coffee compass concat min copy');
  grunt.registerTask('build', 'coffee compass styleguide concat min copy');

};
