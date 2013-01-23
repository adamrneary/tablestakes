fs = require 'fs'
child_process = require 'child_process'
sass = require 'node-sass'

module.exports.css = 'less'
module.exports.name = 'dist'

module.exports.compile = (cb)->
    compileCoffeeSrc ->
        compileCoffeeSpec ->
            compileCoffeeExamples ->
                switch module.exports.css
                    when 'less'
                        compileLess ->
                            cb()
                    when 'scss'
                        compileScss ->
                            cb()

compileCoffeeSpec = (cb)->
    child_process.exec "#{__dirname}/../node_modules/coffee-script/bin/coffee -j #{__dirname}/../examples/public/js/spec.js -cb #{__dirname}/../spec/", (err,stdout,stderr)->
        if stderr
            child_process.exec "#{__dirname}/../node_modules/coffee-script/bin/coffee -p -cb #{__dirname}/spec/", (err,stdout,stderr)->
                console.log 'coffee err: ',stderr
                cb()
        else
            cb()

compileCoffeeSrc = (cb)->
    child_process.exec "#{__dirname}/../node_modules/coffee-script/bin/coffee -j #{__dirname}/../dist/#{module.exports.name}.js -cb #{__dirname}/../src/coffee/", (err,stdout,stderr)->
        if stderr
            child_process.exec "#{__dirname}/../node_modules/coffee-script/bin/coffee -p -cb #{__dirname}/../src/coffee/", (err,stdout,stderr)->
                console.log 'coffee err: ',stderr
                cb()
        else
            cb()

compileCoffeeExamples = (cb)->
    child_process.exec "#{__dirname}/../node_modules/coffee-script/bin/coffee -j #{__dirname}/../examples/public/js/examples.js -cb #{__dirname}/../examples/coffee/", (err,stdout,stderr)->
        if stderr
            child_process.exec "#{__dirname}/../node_modules/coffee-script/bin/coffee -p -cb #{__dirname}/../examples/coffee/", (err,stdout,stderr)->
                console.log 'coffee err: ',stderr
                cb()
        else
            cb()

compileScss = (cb)->
    fs.readFile "#{__dirname}/../src/scss/tables.scss", (err, scssFile)->
        sass.render scssFile.toString(), (err, css)->
            if err
                console.log err
                cb()
            else
                fs.writeFile "#{__dirname}/../dist/#{module.exports.name}.css", css, ->
                    cb()
        , { include_paths: [ "#{__dirname}/../src/scss/"] }

compileLess = (cb)->
    child_process.exec "#{__dirname}/../node_modules/less/bin/lessc #{__dirname}/../src/less/index.less", (err,stdout,stderr)->
        console.log 'less err: ',stderr if stderr
        fs.writeFile "#{__dirname}/../dist/#{name}.css", stdout, ->
            cb()
