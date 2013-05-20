data = []
_.each _.shuffle(['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j']), (d, i) ->
  data.push
    id: d
    type: Math.floor(Math.random() * 10 + 1)

editHandler = (id, field, newValue) ->
  (row[field] = newValue if row.id is id) for row in data
  grid.data(data).render()

columns = [
  id: "id"
  label: "Name"
  classes: "row-heading"
  isSortable: true
,
  id: "type"
  label: "Type"
  isSortable: true
  format: (d) -> "a #{100 - d.type} _#{d.type}"
]

grid = new window.TableStakes()
  .el("#example")
  .columns(columns)
  .data(data)
  .render()

