app = require('showcase')(__dirname)

app.setup 'default', ->
  app.get '/', (req, res) ->
    res.render 'examples/index'

  app.get '/performance', (req, res) ->
    res.render 'performance'
