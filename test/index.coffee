global.assert = require 'assert'
global.glob = {}
glob.server = {}
glob.config = {}
glob.url = "http://localhost:5000/"
glob.request = require 'request'
glob.zombie = require 'zombie'

# note: in current setup, server must be required first to support
#   unit/integration testing to follow
require './server'
require './unit'
require './integration'
require './lint'

after (done)->
    glob.server.kill()
    done()