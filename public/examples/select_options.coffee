data = [
  id: "task 1"
  category: "engineering"
  type: 'category'
,
  id: "task 2"
  category: "qa"
  type: 'category'
,
  id: "task 3"
  category: "engineering"
  type: 'category'
,
  id: "task 4"
  category: "qa"
  type: 'category'
,
  id: "task 5"
  category: "engineering"
  type: 'category'
,
  id: "task 6"
  category: "qa"
  type: 'category'
,
  id: "task 7"
  category: "design"
  type: 'category'
,
  id: "task 8"
  category: "design"
  type: 'category'
,
  id: "task 9"
  category: "sales & ecommerce"
  type: 'account'
,
  id: "task 10"
  category: "other"
  type: 'account'
]

categories = ['engineering', 'design', 'qa']
account = ['sales & ecommerce', 'other']

editHandler = (id, field, newValue) ->
  (row[field] = newValue if row.id is id) for row in data
  grid.data(data).render()

    
isComplete = (d) ->
  d.complete

columns = [
  id: "id"
  label: "Task"
  classes: "row-heading"
,
  id: "category"
  label: "Task category / Account"
  isEditable: true
  editor: 'select'
  selectOptions: (d) ->
    if (d.type == 'category') then categories else account
  onEdit: editHandler
]

grid = new window.TableStakes()
  .el("#example")
  .columns(columns)
  .data(data)
  .render()