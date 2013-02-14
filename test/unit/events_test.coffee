describe "Events", ->
  $ = null
  window = null
  browser = null
  event = null
  before (done)->
    glob.zombie.visit glob.url+"#base", (e, _browser) ->
      browser = _browser
      window = browser.window
      $ = window.$
      event = window.TableStakesLib.Events
      done()

  it 'window.TableStakesLib.Events is function', (done)->
    assert typeof window.TableStakesLib.Events is 'function'
    assert window.TableStakesLib.Events
    done()

  it 'events constructor', (done)->
    assert event
    done()