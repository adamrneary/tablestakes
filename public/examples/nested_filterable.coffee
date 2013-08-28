data = [
  id: 'Account Executive'
  type: 424993
  values: [
    id: 'Duck Philips'
    type: 84997
  ,
    id: 'Ken Cosgrove'
    type: 127500
  ]
,
  id: 'Assistant'
  type: 63760
  values: [
    id: 'Peggy Olson'
    type: 63790
  ]
,
  id: 'Creative'
  type: 573740
  values: [
    id: 'Don Draper'
    type: 148757
  ,
    id: 'Harry Crane'
    type: 127500
  ,
    id: 'Paul Kinsey'
    type: 106243
  ,
    id: 'Pete Campbell'
    type: 84997
  ,
    id: 'Sal Romano'
    type: 106243
  ]
,
  id: 'Partner'
  type: 424993
  values: [
    id: 'Bert Cooper'
    type: 212497
  ,
    id: 'Roger Sterling'
    type: 212497
  ]
]

columns = [
  id: "id"
  label: "Name"
  isNested: true
  classes: 'row-heading'
  isSortable: true
,
  id: "type"
  label: "Type"
  isSortable: true
  format: (d) ->
    numeral(d.type).format('$0.[00]')
]

onDragHandler = (object, target) ->
  u = grid.core.utils
  if target? and object? and
  not u.isChild(target, object) and not u.isParent(target, object)
    u.removeNode(object)
    u.appendNode(target, object)
    grid.data(data).render()

draggable = (d) ->
  d.depth > 1

grid = new window.TableStakes()
  .el('#example')
  .columns(columns)
  .data(data)
  .isDraggable(draggable)
  .dragMode('hierarchy')
  .isDragDestination(true)
  .onDrag(onDragHandler)
  .render()

keyup = -> grid.filter $(this).attr('column'), $(this).val()
$('<input id="filter1" column="id" type="text" value="" />')
  .appendTo('#temp').on 'keyup', keyup
$('<input id="filter2" column="type" type="text" value="" />')
  .appendTo('#temp').on 'keyup', keyup