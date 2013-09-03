# Simple BDD wrapper around casperjs test command
# http://casperjs.org/testing.html#casper-test-command
# For integration testing of main page
#
# Check out http://casperjs.org/api.html#tester
# For more information about assertion API
exports.scenario = (url, desc, func) ->
  baseUrl = "http://localhost:5000/#{url}"
  casper.echo '\n' + baseUrl + '\n' + desc, 'PARAMETER'

  casper.start baseUrl, ->
    @waitForSelector('#example_code')

  func.call(casper)

  casper.run ->
    @test.done()

exports.next = (desc, func) ->
  casper.then ->
    @echo "\n-> #{desc}"
    func.call(@)

pendings = 0
exports.pending = (desc) ->
  casper.then ->
    @echo "\n#{desc}", 'COMMENT'
    pendings++

casper.on 'exit', ->
  return if pendings is 0
  @echo "WARNING: #{pendings} pending", 'RED_BAR'

casper.on 'remote.message', (message) ->
  @echo('log: ' + message)
