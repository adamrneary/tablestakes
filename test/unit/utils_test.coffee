describe "Utils", ->
  table = null
  utils = null
  d = {
    values: ['a'],
    _values: [],
    activatedID: true
  }
  a = {
    values: [],
    activatedID: true
  }
  b = {
    _values: [a],
    activatedID: true
  }

  c = {
    activatedID: true,
    parent: {
      values: [],
      activatedID: true
    }
  }
  c.parent.values = [b, c]
  c.parent.children = [b, c]

  f = {
    values: [a, c],
    activatedID: true
  }

  it 'window.TableStakesLib.Utils is function', (done) ->
    assert typeof window.TableStakesLib.Utils is 'function'
    done()

  it 'utils constructor', (done) ->
    utils = new window.TableStakesLib.Utils
      core: {
        utils:{
          deactivateAll: (d) ->
            d.activatedID = null
          hasChildren: ->
            true
          isChild: ->
            true
        }
        data:[{values:[{_id:"0_0", values:[{_id:"0_0_0"}]}], _id:"0"}]
        columns: [{id: 'id'},{id: 'type'}]
        nodes: [{_id:"0"},{_id:"0_0"},{_id:"0_0_0"}]
        table: {
          gridFilteredData: [
            {values:[{_id:"0_0", values:[{_id:"0_0_0"}]}], _id:"0"}
          ]
          setID: ->
            return true
        }
      }
    assert utils
    done()

  it 'hasChildren', (done)->
    assert utils.hasChildren(d)
    assert utils.hasChildren(a) is 0
    done()

  it 'folded', (done)->
    assert utils.folded(d) is 0
    done()

  it 'appendNode', (done)->
    assert d.values.length is 1
    utils.appendNode(d, a)
    assert d.values.length is 2

    assert b._values.length is 1
    utils.appendNode(b, a)
    assert b._values.length is 2

    utils.appendNode(c, a)
    assert c.values.length is 1
    done()

  it 'pastNode', (done)->
    #console.log c.parent.values
    utils.pastNode(c, a)
    assert c.parent.values[2] is a
    done()

  it 'removeNode', (done)->
    utils.removeNode(c)
    assert c.parent.values.length is 2
    done()

  it 'findNextNode', (done)->
    assert utils.findNextNode({_id: "0_0"})._id is "0_0_0"
    assert utils.findNextNode({_id:"0_0_0"}) is null
    done()

  it 'findPrevNode', (done)->
    assert utils.findPrevNode({_id: "0_0_0"})._id is "0_0"
    assert utils.findPrevNode({_id:"0_0"}) is null
    done()

  it 'findNodeByID', (done)->
    utils.findNodeByID("0_0") is { _id:"0_0", values:[{_id:"0_0_0"}]}
    done()

  it 'getCurrentColumnIndex', (done)->
    assert utils.getCurrentColumnIndex('id') is 0
    done()

  it 'deactivateAll', (done)->
    utils.deactivateAll(f)
    assert f.activatedID is null
    assert c.activatedID is null
    assert a.activatedID is null
    utils.deactivateAll(b)
    assert b.activatedID is null
    done()

  it 'isChild', (done)->
    assert utils.isChild(d, b)
    assert utils.isChild(a, f)
    utilsTest2 = new window.TableStakesLib.Utils
      core: {
        utils:{
          deactivateAll: (d) ->
            d.activatedID = null
          hasChildren: ->
            false
          isChild: ->
            false
        }
      }
    assert utilsTest2.isChild(f, a) is false
    done()

  it 'isParent', (done)->
    utils.isParent(a, d)
    utilsTest = new window.TableStakesLib.Utils
      core: {
        utils:{
          deactivateAll: (d) ->
            d.activatedID = null
          hasChildren: ->
            false
        }
      }
    utilsTest.isParent(a, d)
    done()
