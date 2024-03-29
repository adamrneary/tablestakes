data = _.map ['Account Executive','Assistant','Creative','Partner'], (type, i) ->
  values = _.map(_.range(5), (j)->
    id: "#{i}#{j}"
    type: (1000*Math.random())
    values: (_.map(_.range(5), (k)->
      id: "#{i}#{j}#{k}"
      type: Math.floor(100*Math.random())
    ))
  )

  id: type
  values: values
  type: (_.reduce(values, ((memo, val) -> memo + val.type), 0))

columns = [
  id: "id"
  label: "Name"
  isNested: true
  classes: 'row-heading'
  isSortable: true
  format: (d) ->
    if d['values']?
      "<strong>#{d.id}</strong>"
    else
      d.id
,
  id: "type"
  label: "Type"
  isSortable: true
  format: (d) ->
    numeral(d.type).format('$0.00')
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
  .height(500)
  .columns(columns)
  .data(data)
  .isDraggable(draggable)
  .dragMode('hierarchy')
  .isDragDestination((d)->
    d.id in ['Account Executive','Assistant','Creative','Partner']
  )
  .onDrag(onDragHandler)
  .render()

keyup = -> grid.filter _.pluck(columns, "id"), $(this).val()
$('<input id="filter1" column="id" type="text" value="" />')
  .appendTo('#temp').on 'keyup', keyup
