describe "Events", ->
  event = null

  it 'window.TableStakesLib.Events is function', (done)->
    assert typeof window.TableStakesLib.Events is 'function'
    assert window.TableStakesLib.Events
    done()

  it 'events constructor', (done)->
    event = new window.TableStakesLib.Events
        core: {}
    assert event
    done()

  it 'resizeDrag', (done)->
    assert event.resizeDrag
    done()


