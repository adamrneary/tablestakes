app   = require('showcase').app(__dirname)
docco = require('showcase').docco

app.configure 'development', ->
  require('brunch').watch({})

app.setup ->
  app.get '/', (req, res) ->
    res.render 'examples/index'

  app.get '/performance', (req, res) ->
    res.render 'layout', layout: false

  app.get '/styleguide', (req, res) ->
    res.render 'examples/styleguide'

  app.get '/tests', (req, res) ->
    res.render 'examples/iframe', url: '/test_runner.html'

  app.get '/documentation', (req, res) ->
    res.render 'examples/iframe', url: '/docs/tablestakes.html'

docco(files: '/src/coffee/*', output: '/public/docs', root: __dirname, layout: 'linear')