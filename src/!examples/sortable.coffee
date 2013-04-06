data = [
  id: "a"
  type: "1"
,
  id: "d"
  type: "3"
,
  id: "c"
  type: "2"
,
  id: "e"
  type: "7"
,
  id: "b"
  type: "6"
,
  id: "z"
  type: "8"
,
  id: "x"
  type: "10"
,
  id: "f"
  type: "5"
,
  id: "l"
  type: "4"
,
  id: "n"
  type: "2"
,
  id: "L"
  type: "6"
,
  id: "N"
  type: "9"
,
  id: "1"
  type: "11"
]

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
]

grid = new window.TableStakes()
  .el("#example")
  .columns(columns)
  .data(data)
  .render()

