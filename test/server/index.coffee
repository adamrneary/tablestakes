global.assert = require 'assert'
global.request = require 'request'
spawn = require('child_process').spawn
server = {}

describe 'test server', ->
    it 'run server', (done)->
        server = spawn 'node', ['run.js']
        server.stdout.on 'data', (data)->
            data = data.toString()
            process.stdout.write data
            if data is 'server start on port 3000\n'
                done()
        server.stderr.on 'data', (data)->
            process.stdout.write data.toString()

    it 'test localhost:3000', (done)->
        request.get 'http://localhost:3000', (err,res,body)->
            assert body
            done()

    it 'test localhost:3000/styleguide', (done)->
        request.get 'http://localhost:3000/styleguide', (err,res,body)->
            assert body
            done()

    it 'test localhost:3000/mocha', (done)->
        request.get 'http://localhost:3000/mocha', (err,res,body)->
            assert body
            done()

    after (done)->
        server.kill()
        done()
