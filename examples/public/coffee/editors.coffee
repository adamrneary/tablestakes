data = [
  id: "task 1"
  category: "engineering"
  date: '2013-01-01'
  complete: true
,
  id: "task 2"
  category: "qa"
  date: '2013-02-01'
  complete: true
,
  id: "task 3"
  category: "engineering"
  date: '2013-03-01'
  complete: true
,
  id: "task 4"
  category: "qa"
  date: '2013-04-01'
  complete: false
,
  id: "task 5"
  category: "engineering"
  date: '2013-05-01'
  complete: false
,
  id: "task 6"
  category: "qa"
  date: '2013-06-01'
  complete: false
,
  id: "task 7"
  category: "design"
  date: '2013-07-01'
  complete: false
,
  id: "task 8"
  category: "design"
  date: '2013-08-01'
  complete: false
,
  id: "task 9"
  category: "engineering"
  date: '2013-09-01'
  complete: false
,
  id: "task 10"
  category: "qa"
  date: '2013-10-01'
  complete: false
]

categories = ['engineering', 'design', 'qa']

columns = [
  id: "id"
  label: "Task"
  classes: "row-heading"
  isEditable: true
,
  id: "category"
  label: "Task category"
  isEditable: true
  editor: 'select'
  selectOptions: categories
,
  id: "date"
  label: "Date due"
  isEditable: true
  editor: 'calendar'
,
  id: "complete"
  label: "Is complete"
  isEditable: true
  editor: 'boolean'
]

grid = new window.TableStakes()
  .el("#example")
  .columns(columns)
  .data(data)
  .render()