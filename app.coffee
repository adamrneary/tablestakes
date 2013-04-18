app = require('showcase').app(__dirname)
kss = require('kss')
fs  = require('fs')

{isAuth, docco} = require('showcase')

app.configure 'development', ->
  require('brunch').watch({})

app.configure 'production', ->
  app.set('github-client-id', '25505fffcba6c3f4b29e')
  app.set('github-client-secret', '434fbe2831a94b1c9a7931734e769cf2ac25ee09')

app.get '/', isAuth, (req, res) ->
  res.render 'examples/index'

app.get '/performance', isAuth, (req, res) ->
  res.render 'layout', layout: false

app.get '/tests', isAuth, (req, res) ->
  res.render 'examples/iframe', url: '/test_runner.html'

app.get '/documentation', isAuth, (req, res) ->
  res.render 'examples/iframe', url: '/docs/tablestakes.html'

app.get '/styleguide', isAuth, (req, res) ->
  kss.traverse "#{__dirname}/src/scss", { markdown: false }, (err, styleguide) ->
    return res.send(500, err) if err
    res.render 'examples/styleguide', sections: getSections(styleguide)

app.start()

# Generate docco documenation
docco(files: '/src/coffee/*', output: '/public/docs', root: __dirname, layout: 'linear')

# Generate kss documentation
getSections = (styleguide) ->
  styleguide.section().map (section) ->
    html                     = fs.readFileSync("#{__dirname}/views/sections/#{section.reference()}.html").toString()
    section.data.filename    = 'tablestakes.scss'
    section.data.description = section.data.description.replace(/\n/g, "<br />")
    section.data.example     = html

    section.modifiers = section.modifiers().map (modifier) ->
      modifier.data.example = html
      name: modifier.name()
      description: modifier.description()
    section
