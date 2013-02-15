process.env.NODE_ENV = 'testing'

global.assert = require 'assert'
global.should = require('chai').should()
global.glob = {}
glob.server = {}
glob.config = require '../server/config'
glob.url = "http://localhost:#{glob.config.port}/"
glob.request = require 'request'
glob.zombie = require 'zombie'

compile = require('../server/compiler')

# kill test server, if exist
before (done)->
  glob.request.get "#{glob.url}pid?secret=#{glob.config.secret}", {json: true}, (err,res,body) ->
    if !err
      if res.statusCode is 200 and body
        pid = body.pid
        process.kill pid
        process.exit()
    else
      done()

# run server in test mode
before (done)->
    glob.server = require('child_process').spawn 'node', ['run.js'], { env: process.env } 
    glob.server.stdout.on 'data', (data) ->
      data = data.toString()
      process.stdout.write data
      if data is "server start on port #{glob.config.port}\n"
        done()
    glob.server.stderr.on 'data', (data) ->
      process.stdout.write data.toString()

# compile src
#before (done)->
  #compile ->
    #done()

require './server'
require './unit'
require './integration'
require './lint'
