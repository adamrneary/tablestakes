describe 'column', ->
  it 'constructor', ->
    column = new window.TableStakesLib.Column(a: 'b')
    assert column
    assert column.a is 'b'
