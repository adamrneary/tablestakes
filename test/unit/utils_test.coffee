describe "Utils", ->
  data = [
    id: "NVD3"
    type: "ahaha"
    values: [
      id: "Charts"
      _values: [
        id: "Simple Line"
        type: "Historical"
      ,
        id: "Scatter / Bubble"
        type: "Snapshot"
      ,
        id: "Stacked / Stream / Expanded Area"
        type: "Historical"
      ,
        id: "Discrete Bar"
        type: "Snapshot"
      ,
        id: "Grouped / Stacked Multi-Bar"
        type: "Snapshot / Historical"
      ,
        id: "Horizontal Grouped Bar"
        type: "Snapshot"
      ,
        id: "Line and Bar Combo"
        type: "Historical"
      ,
        id: "Cumulative Line"
        type: "Historical"
      ,
        id: "Line with View Finder"
        type: "Historical"
      ]
    ,
      id: "Chart Components"
      values: [
        id: "Legend"
        type: "Universal"
      ]
    ]
  ,
    id: "New Root"
    type: "tatata"
    classes: "rowcustom1"
    values: [
      id: "1"
      type: "123"
      classes: "rowcustom"
    ]
  ]

  columns = [
    id: "id"
    label: "Name"
    classes: 'row-heading'
    isEditable: false
    isNested: true
  ,
    id: "type"
    label: "Type"
    isEditable: false
  ]

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

