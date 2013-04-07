app   = require('showcase').app(__dirname)
docco = require('showcase').docco

app.configure 'development', ->
  require('brunch').watch({})

app.setup ->
  app.get '/', (req, res) ->
    res.render 'examples/index'

  app.get '/performance', (req, res) ->
    res.render 'layout', layout: false

docco(files: '/src/coffee/*', output: '/public/docs', root: __dirname)