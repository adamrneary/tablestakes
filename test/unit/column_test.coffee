describe "column", ->

  it 'constructor', (done) ->
    column = new window.TableStakesLib.Column
        a: 'b'
    assert column
    done()

