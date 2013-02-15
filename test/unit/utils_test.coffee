describe "Utils", ->
  $ = null
  window = null
  browser = null
  utils = null
  before (done)->
    glob.zombie.visit glob.url+"#base", (e, _browser) ->
      browser = _browser
      window = browser.window
      $ = window.$
      utils = window.TableStakesLib.Utils
      done()

  it 'window.TableStakesLib.Events is function', (done)->
    assert typeof utils is 'function'
    done()

  it 'events constructor', (done)->
    assert utils
    done()
