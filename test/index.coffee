global.assert = require 'assert'
global.glob = {}
glob.server = {}
glob.config = {}
glob.url = "http://localhost:5000/"
glob.request = require 'request'
glob.zombie = require 'zombie'

require './server'
require './integration'
# require './unit'

after (done)->
    glob.server.kill()
    done()
