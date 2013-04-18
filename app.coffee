app = require('showcase').app(__dirname)
kss = require('kss')
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
    getSections styleguide.section(), (sections) =>
      res.render 'examples/styleguide', sections: sections

app.start()

# Generate documenation
docco(files: '/src/coffee/*', output: '/public/docs', root: __dirname, layout: 'linear')

getSections = (sections, cb) ->
  jadeiIns = require('jade')
  fs   = require('fs')

  jadeDir = "#{__dirname}/views/sections/"
  for section in sections
    section.data.filename = 'tables.scss'
    section.data.description = section.data.description
      .replace(/\n/g, "<br />")

    jadePath = "#{jadeDir}#{section.reference()}.jade"
    jade = fs.readFileSync jadePath
    if jade
      locals =
        section: section
        className: '$modifier'
      html = jadeiIns.compile(jade, {pretty: true})(locals)
      section.data.example = html

      modifiers = []
      for modifier in section.modifiers()
        a = { className: modifier.className() }
        modifier.data.example = jadeiIns.compile(
          jade,
          {pretty: true}
        )(a)
        modifiers.push(
          name: modifier.name()
          description: modifier.description()
          data: { example: modifier.data.example }
        )
      section.modifiers = modifiers
  cb(sections) if cb
