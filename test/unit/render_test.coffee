describe "Render", ->
  render = null
  table = null
  table2 = null
  data = [
    id: "task 1"
    category: "engineering"
    date: '2013-01-01'
    complete: true
    classes: "total"
  ,
    id: "task 2"
    category: "qa"
    date: '2013-02-01'
    complete: true
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
    showCount: true
  ,
    id: "complete"
    label: "Is complete"
    isEditable: true
    editor: 'boolean'
    onEdit: editHandler
  ]

  it 'is a function', ->
    assert window.TableStakes
    assert typeof window.TableStakes is 'function'

  it 'window.TableStakesLib.Core', ->
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
      .dragMode('reorder')
      .isDraggable(true)
      .render()
      .rowClasses (d) -> "total2" if d.etc is 'etc6'

  it 'render constructor', ->
    render = new window.TableStakesLib.Core
    render['table'] = {
      isDraggable: ->
        false
    }
    assert render

  #it '_buildData', ->
    #data2 = [null]
    #table2 = new window.TableStakes()
      #.data(data2)

  it 'update', ->
    rendertest = new window.TableStakesLib.Core
    rendertest['table'] = {
      isInRender: false,
      isDraggable: ->
        false
      update: ->
        true
    }
    rendertest['selection'] = {
      transition: ->
        call: ->
          true
      }

    assert rendertest.update()

  # it 'render', ->
  #   rendertest = new window.TableStakesLib.Core
  #   rendertest['data'] = data
  #   rendertest['table'] = {
  #     isInRender: false,
  #     el: ->
  #       true
  #     isDraggable: ->
  #       false
  #     update: ->
  #       true
  #   }
  #   rendertest['selection'] = {
  #     transition: ->
  #       call: ->
  #         true
  #     }

  #   assert rendertest.render()

