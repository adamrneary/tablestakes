app    = require('showcase')(__dirname)
brunch = require('brunch')

app.configure 'development', ->
  brunch.watch({})

app.setup null, ->
  app.get '/', (req, res) ->
    res.render 'examples/index'

  app.get '/performance', (req, res) ->
    res.render 'performance'
