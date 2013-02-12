name = 'tablestakes'

port = process.env.PORT or 5000

modules = 
    http: require 'http'
    fs: require 'fs'
    express: express = require 'express'
    path: require 'path'
    kss: require 'kss'
    jade: require 'jade'
    coffeelint: require 'coffeelint'
    #async: require 'async'

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
    for section in sections
        section.data.filename = 'tables.scss'
        section.data.description = section.data.description.replace(/\n/g, "<br />")
        jade = null
        try
            jade = modules.fs.readFileSync "#{__dirname}/../examples/views/sections/#{section.reference()}.jade"
        if jade
            locals =
                section: section
                className: '$modifier'
            html = modules.jade.compile(jade, {pretty: true})(locals)
            section.data.example = html
            for modifier in section.modifiers()
                modifier.data.example = modules.jade.compile(jade, {pretty: true})({className: modifier.className()})
    cb sections

app.get '/', (req,res)->
    compile ->
        res.render 'index'
            page: 'index'

 app.get '/documentation', (req,res)->
    compile ->
        docs = {}
        docsPath = "#{__dirname}/../test/docs/"
        docFiles = modules.fs.readdirSync docsPath
        for docFile in docFiles
            if docFile.substr(docFile.length-4) == 'html'
                htmlBody = modules.fs.readFileSync docsPath + docFile, 'utf-8'
                jsReg = /<body>([\s\S]*?)<\/body>/gi
                container = jsReg.exec(htmlBody)
                docs[docFile] = container[1]

        res.render 'documentation'
            docs: docs
            page: 'documentation'


app.get '/test', (req,res)->
    compile ->
        errors = {}
        pathes = {}

        path = "#{__dirname}/../src/coffee/"
        files = modules.fs.readdirSync path
        for f in files
            errors[f] = modules.coffeelint.lint modules.fs.readFileSync path + f, 'utf-8' 

        path2="#{__dirname}/../examples/public/coffee/"
        files2 = modules.fs.readdirSync path2
        for t in files2
            errors[t] = modules.coffeelint.lint modules.fs.readFileSync path2 + t, 'utf-8' 

        path3="#{__dirname}/../server/"
        files3 = modules.fs.readdirSync path3
        for d in files3
            errors[d] = modules.coffeelint.lint modules.fs.readFileSync path3 + d, 'utf-8' 

        res.render 'mocha'
            errors: errors
            page: 'mocha'

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
                    page: 'styleguide'

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

#app.get '/lint', (req, res)->
    ##getLintParser = (path)->
        ##errors = {}
        ##files = modules.fs.readdirSync path
        ##for file in files
            ##errors[file] = modules.coffeelint.lint modules.fs.readFileSync path + file, 'utf-8' 
        ##errors

    #compile ->
        #errors = {}
        #pathes = {}
        ##pathes = ["#{__dirname}/../src/coffee/", "#{__dirname}/../examples/public/coffee/", "#{__dirname}/../server/"]
        ##for path in pathes
            ##errors.push getLintParser(path)
        ##console.log errors
        #path = "#{__dirname}/../src/coffee/"
        #files = modules.fs.readdirSync path
        #for f in files
            #errors[f] = modules.coffeelint.lint modules.fs.readFileSync path + f, 'utf-8' 

        #path2="#{__dirname}/../examples/public/coffee/"
        #files2 = modules.fs.readdirSync path2
        #for t in files2
            #errors[t] = modules.coffeelint.lint modules.fs.readFileSync path2 + t, 'utf-8' 

        #path3="#{__dirname}/../server/"
        #files3 = modules.fs.readdirSync path3
        #for d in files3
            #errors[d] = modules.coffeelint.lint modules.fs.readFileSync path3 + d, 'utf-8' 

        #res.render 'lint'
            #errors: errors
            #page: 'lint'

modules.http.createServer(app).listen port, ->
    console.log  'server start on port '+port
