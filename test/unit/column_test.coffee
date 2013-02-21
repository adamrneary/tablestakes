describe "column", ->

  it 'constructor', (done) ->
    column = new window.TableStakesLib.Column
      a: 'b'
    assert column
    assert column.a is 'b'
    done()