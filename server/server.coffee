name = 'tablestakes'

port = process.env.PORT or 3000

modules = 
    http: require 'http'
    fs: require 'fs'
    express: express = require 'express'
    path: require 'path'
    kss: require 'kss'
    jade: require 'jade'
    async: require 'async'

app = express()

app.configure ->
    app.set('port', port);
    app.set('views', __dirname + '/../examples/views');
    app.set('view engine', 'jade');
    app.use express.favicon()
    app.use express.cookieParser()
    app.use express.bodyParser()
    app.use express.methodOverride()
    app.use app.router
    app.use express.static "#{__dirname}/../examples/public/"
    app.use express.errorHandler
        dumpExceptions: true
        showStack: true

compiler = require('./compiler')
compiler.name = name
compiler.css = 'scss'
compile = require('./compiler').compile

getSections = (sections,cb)->
    asyncArr = []
    jade_sections = modules.fs.readdirSync "#{__dirname}/../examples/views/sections/"
    for jade_section in jade_sections
        ((jade_section)->
            asyncArr.push (done)->
                jade = modules.fs.readFileSync "#{__dirname}/../examples/views/sections/#{jade_section}"
                if jade
                    modules.jade.render jade, {pretty: true}, (err,html)->
                        for section in sections
                            if section.data.reference is jade_section.replace /\.jade/g, ''
                                section.data.example = html
                                break
                        done()
                else
                    done()
        )(jade_section)
    modules.async.parallel asyncArr, ->
        for section in sections
            section.data.description = section.data.description.replace(/\n/g, "<br />")
        cb sections

app.get '/', (req,res)->
    compile ->
        res.render 'index'
        #html = modules.fs.readFileSync __dirname+'/views/index.html'
        #res.setHeader 'Content-Type', 'text/html'
        #res.setHeader 'Content-Length', html.length
        #res.end html

app.get '/mocha', (req,res)->
    compile ->
        res.render 'mocha'

app.get '/styleguide', (req,res)->
    compile ->
        options = 
            markdown: false
        #modules.kss.traverse "#{__dirname}/../dist/#{name}.css", options, (err, styleguide)->
        #modules.kss.traverse "#{__dirname}/../dist/", options, (err, styleguide)->
        modules.kss.traverse "#{__dirname}/../src/", options, (err, styleguide)->
            getSections styleguide.section(), (sections)->
                res.render 'styleguide'
                    sections: sections

app.get "/js/#{name}.js", (req,res)->
    script = modules.fs.readFileSync "#{__dirname}/../dist/#{name}.js"
    res.setHeader 'Content-Type', 'text/javascript'
    res.setHeader 'Content-Length', script.length
    res.end script

app.get "/css/#{name}.css", (req,res)->
    style = modules.fs.readFileSync "#{__dirname}/../dist/#{name}.css"
    res.setHeader 'Content-Type', 'text/css'
    res.setHeader 'Content-Length', style.length
    res.end style

modules.http.createServer(app).listen port, ->
    console.log  'server start on port '+port
