app = require('showcase')(__dirname)

app.configure 'development', ->
  require('brunch').watch({})

app.setup null, ->
  app.get '/', (req, res) ->
    res.render 'examples/index'

  app.get '/performance', (req, res) ->
    res.render 'performance'
