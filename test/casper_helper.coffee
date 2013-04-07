# Simple BDD wrapper around casperjs test command
# http://casperjs.org/testing.html#casper-test-command
# For integration testing of main page
#
# Check out http://casperjs.org/api.html#tester
# For more information about assertion API
exports.scenario = (url, func) =>
  baseUrl = "http://localhost:5000/#{url}"
  casper.echo '\n' + baseUrl, 'PARAMETER'

  casper.start baseUrl, ->
    @waitForSelector('#example_code')

  func.call(casper)

  casper.run ->
    @test.done()

exports.next = (desc, func) ->
  casper.then ->
    @echo "\n#{desc}", 'COMMENT'
    func.call(@)
