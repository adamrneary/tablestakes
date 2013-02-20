describe "Render", ->
  render = null
  table = null
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

  editHandler = (id, field, newValue) ->
    (row[field] = newValue if row.id is id) for row in data
    table.data(data).render()

  columns = [
    id: "id"
    label: "Task"
    classes: "row-heading"
    isEditable: true
    onEdit: editHandler
  ,
    id: "category"
    label: "Task category"
    isEditable: true
    editor: 'select'
    selectOptions: categories
    onEdit: editHandler
  ,
    id: "date"
    label: "Date due"
    isEditable: true
    editor: 'calendar'
    onEdit: editHandler
  ,
    id: "complete"
    label: "Is complete"
    isEditable: true
    editor: 'boolean'
    onEdit: editHandler
  ]

  it 'is a function', (done) ->
    assert window.TableStakes
    assert typeof window.TableStakes is 'function'
    done()

  it 'window.TableStakesLib.Core', (done) ->
    deleteCheck = (d) ->
      d.type is 'Historical' or d.type is 'Snapshot'

    deleteHandler = (id) ->
      data = _.reject(data, (row) -> row.id is id)
      table.data(data).render()

    table = new window.TableStakes()
      .el("#example")
      .columns(columns)
      .data(data)
      .isDeletable(deleteCheck)
      .onDelete(deleteHandler)
      .render()
      .dragMode('reorder')
      .isDraggable(true)

    assert render = new window.TableStakesLib.Core
    done()
    
  it 'render constructor', (done)->
    render = new window.TableStakesLib.Core
    assert render
    done()
    
  it 'update', (done)->
    rendertest = new window.TableStakesLib.Core
    rendertest['table'] = {
      isInRender: false,
      update: ->
        true
    }
    rendertest['selection'] = {
      transition: ->
        call: ->
          true
      }

    rendertest.update()
    done()

  #it 'update', (done)->
    #render.update()
    #done()
