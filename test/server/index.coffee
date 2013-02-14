describe 'server', ->

  it 'run', (done) ->
    glob.server = require('child_process').spawn 'node', ['run.js']
    glob.server.stdout.on 'data', (data) ->
      data = data.toString()
      process.stdout.write data
      if data is 'server start on port 5000\n'
        done()
    glob.server.stderr.on 'data', (data) ->
      process.stdout.write data.toString()

  it "test #{glob.url}", (done) ->
    glob.request.get glob.url, (err,res,body) ->
      assert body
      done()

  it "test #{glob.url}documentation", (done) ->
    glob.request.get glob.url+"documentation", (err,res,body) ->
      assert body
      done()

  it "test #{glob.url}test", (done)->
    glob.request.get glob.url+"test", (err,res,body) ->
      assert body
      done()

  it "test #{glob.url}styleguide", (done) ->
    glob.request.get glob.url+"styleguide", (err,res,body) ->
      assert body
      done()

