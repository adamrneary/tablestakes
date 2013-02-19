describe "Utils", ->
  table = null
  utils = null
  d = {
    _hiddenvalues: [],
    values: ['a'],
    _values: [],
    _id: "0_6",
    activatedID: null,
    changedID: [],
    depth: 1,
    id: "Horizontal Grouped Bar",
    parent: {},
    type: "Snapshot",
    x: 0.5,
    y: 1
  }

  it 'window.TableStakesLib.Utils is function', (done) ->
    assert typeof utils is 'function'
    done()

  it 'utils constructor', (done) ->
    utils = new window.TableStakesLib.Utils
      core: {}
    assert utils
    done()

  it 'isChild', (done) ->
    assert true
    done()

  it 'isParent', (done) ->
    assert true
    done()

  it 'hasChildren', (done)->
    assert utils.hasChildren(d)
    a = {
      values: [],
      _values: [],
      _hiddenvalues: [],
      _id: "0_6",
      activatedID: null,
      changedID: [],
      depth: 1,
      id: "Horizontal Grouped Bar",
      parent: {},
      type: "Snapshot",
      x: 0.5,
      y: 1
    }
    assert utils.hasChildren(a) is 0
    done()

  it 'folded', (done)->
    assert utils.folded(d) is 0
    done()

