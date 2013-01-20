port = process.env.PORT or 5000

modules = 
    http: require 'http'
    fs: require 'fs'
    child_process: require 'child_process'
    express: express = require 'express'
    path: path = require 'path'

app = express()

app.configure ->
    app.use express.favicon()
    app.use express.cookieParser()
    app.use express.bodyParser()
    app.use express.methodOverride()
    app.use app.router
    app.use express.static(path.join(__dirname, 'examples'))
    app.use express.errorHandler
        dumpExceptions: true
        showStack: true

app.get '/', (req,res)->
    html = modules.fs.readFileSync __dirname+'/examples/index.html'
    res.setHeader 'Content-Type', 'text/html'
    res.setHeader 'Content-Length', html.length
    res.end html

modules.http.createServer(app).listen port, ->
    console.log  'server start on port '+port
