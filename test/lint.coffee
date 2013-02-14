describe 'coffeelint', ->
  glob.lint = require('child_process').spawn 'coffeelint', ['-r',
    './examples'
    './server'
    './src'
    './test'
  ]
  glob.lint.stdout.on 'data', (data) ->
    data = data.toString()
    process.stdout.write data