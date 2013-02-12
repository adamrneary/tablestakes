data = [
  id: "task 1"
  category: "engineering"
  date: '2013-01-01'
  complete: true
,
  id: "task 2"
  category: "engineering"
  date: '2013-01-01'
  complete: true
,
  id: "task 3"
  category: "engineering"
  date: '2013-01-01'
  complete: true
,
  id: "task 4"
  category: "engineering"
  date: '2013-01-01'
  complete: true
,
  id: "task 5"
  category: "engineering"
  date: '2013-01-01'
  complete: true
,
  id: "task 6"
  category: "engineering"
  date: '2013-01-01'
  complete: true
,
  id: "task 7"
  category: "engineering"
  date: '2013-01-01'
  complete: true
,
  id: "task 8"
  category: "engineering"
  date: '2013-01-01'
  complete: true
,
  id: "task 9"
  category: "engineering"
  date: '2013-01-01'
  complete: true
,
  id: "task 10"
  category: "engineering"
  date: '2013-01-01'
  complete: true
]

columns = [
  id: "id"
  label: "Task"
  classes: "row-heading"
  isEditable: true
,
  id: "category"
  label: "Date due"
  isEditable: true
,
  id: "date"
  label: "Date due"
  isEditable: true
,
  id: "complete"
  label: "Is complete"
  isEditable: true
]

grid = new window.TableStakes()
  .el("#example")
  .columns(columns)
  .data(data)
  .render()