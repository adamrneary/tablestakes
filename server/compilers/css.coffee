module.exports = class Css

  fs: require 'fs'

  path: glob.config.path.css

  compile_src: (cb) =>
    if process.env.NODE_ENV is 'development'
      @["compile_src_#{glob.config.server.css_engine}"] =>
        cb() if cb
    else
      cb?()

  compile_src_scss: (cb) =>
    @sass = require 'node-sass'
    @fs.readFile @path.src.from, (err, scssFile) =>
      scssFile = '' unless scssFile?
      @sass.render scssFile.toString(), (err, css) =>
        if err
          console.error err
          process.exit()
        else
          @fs.writeFile @path.src.to, css, =>
            cb() if cb
      , { include_paths: @path.src.include_paths }

  #TODO
  #less: (cb) ->
    #lesscPath = "#{__dirname}/../node_modules/less/bin/lessc"
    #lessDest = "#{__dirname}/../src/less/index.less"
    #child_process.exec "#{lesscPath} #{lessDest}", (err,stdout,stderr) ->
      #console.log 'less err: ',stderr if stderr
      #fs.writeFile "#{__dirname}/../dist/#{name}.css", stdout, ->
        #cb()

