window.TableStakesLib = {} unless window.TableStakesLib
class window.TableStakesLib.Core

  constructor: (options) ->
    @utils = new window.TableStakesLib.Utils
      core: @
    @events = new window.TableStakesLib.Events
      core: @

  set: (options) ->
    @table = options.table
    @selection = options.selection
    @data = options.data
    @columns = @table.columns()

  update: ->
    @table.isInRender = true
    @selection.transition().call (selection) =>
      @table.update selection

  # responsible for &lt;table&gt; and contents
  #
  # calls renderHead() for &lt;thead&gt; and contents
  # calls renderBody() for &lt;tbody&gt; and contents
  render: ->
    @_buildData()
    wrap = d3.select(@table.el())
      .selectAll("div")
      .data([[@nodes]])
    wrapEnter = wrap.enter().append("div")
    @tableEnter = wrapEnter.append("table")
    @tableObject = wrap.select("table")
      .classed(@table.tableClassName,true)
      .attr("style", "table-layout:fixed;")

    @_renderHead(@tableObject) if @table.header
    @_renderBody(@tableObject)
    @_makeDraggable(@tableObject) unless @table.isDraggable() is false
    @_makeDeletable(@tableObject) unless @table.isDeletable() is false

  _buildData: ->
    @data[0] = id: @table.noData unless @data[0]
    @tree = d3.layout.tree().children (d) -> d.values
    @nodes = @tree.nodes(@data[0])

    # calculate number of columns
    depth = d3.max(@nodes, (node) -> node.depth)
    @tree.size [@table.height, depth * @table.childIndent]

  # responsible for &lt;thead&gt; and contents
  _renderHead: (tableObject) ->
    self = @

    # create table header and row
    theadRow = tableObject.selectAll("thead")
      .data((d) -> d)
      .enter()
        .append("thead")
        .append("tr")

    # append a &lt;th&gt; for each column
    th = theadRow.selectAll("th")
      .data(@columns)
      .enter()
        .append("th")
          .text((d) -> d.label)
          .attr("ref", (d,i) -> i)
          .attr("class", (d) => @_columnClasses(d))
          .style('width', (d) -> d.width)

    # for now, either all columns are resizable or none, set in table config
    theadRow.selectAll("th").call(@_makeResizable) if @table.isResizable()
    @

  # responsible for &lt;tbody&gt; and contents
  _renderBody: (tableObject) ->
    @tbody = tableObject.selectAll("tbody").data((d) -> d)
    @tbody.enter().append "tbody"
    @_renderRows()

  _enterRows: ->
    @enterRows = @rows
      .enter()
        .append("tr")
        .attr("class", (d) => @_rowClasses(d))

  _updateRows: ->
    self = @

    @updateRows = @rows.order()
    @_addRowEventHandling()
    @updateRows.select('.expandable')
      .classed('folded', @utils.folded)

  _addRowEventHandling: ->
    events =
      click: 'elementClick'
      dblclick: 'elementDblclick'
      mouseover: 'elementMouseover'
      mouseout: 'elementMouseout'

    addEvent = (key, value) =>
      @updateRows.on key, (d) => @table.dispatch.elementClick
        row: @
        data: d
        pos: [d.x, d.y]

    _.each events, (value, key) => addEvent(key, value)

  _exitRows: ->
    @rows
      .exit()
        .remove()

  _renderRows: ->
    @rows = @tbody.selectAll("tr")
      .data(((d) -> d), (d) -> d.id)
    @_enterRows()
    @_updateRows()
    @_exitRows()

    d3.select(@enterRows[0][0])
      .style("display", "none") if @enterRows[0][0]
    @_renderEnterRows()
    @_renderUpdateRows()

  _renderEnterRows: ->
    self = @
    @columns.forEach (column, column_index) =>
      @enterRows.append('td')
        .each (d, i) -> self._renderCell(column, d, @)

  _renderUpdateRows: ->
    self = @
    @updateRows.selectAll('td').each (d, i) ->
      self._renderCell(self.columns[i], d, @) if self.columns[i]?

  _renderCell: (column, d, td) ->
    d3.select(td)
      .attr('meta-key', column.id)
      .attr('class', (d) => @_cellClasses(d, column))
      .text((d) -> d[column.id] or '-')

    isEditable = @utils.ourFunctor(column.isEditable, d)
    @_makeNested(td) if @utils.ourFunctor(column.isNested, d)
    @_makeEditable(d, td, column) if isEditable
    @_makeChanged(d, td, column)
    @_makeBoolean(d, td, column) if column.editor is 'boolean' and isEditable
    @_makeSelect(d, td, column) if column.editor is 'select' and isEditable
    @_makeButton(d, td, column) if column.editor is 'button' and isEditable
    @_addShowCount(d, td, column) if column.showCount

  # ## "Class methods" (tongue in cheek) define classes to be applied to tags
  # Note: There are other methods that add/remove classes but these are the
  # primary points of contact

  # responsible for &lt;th&gt; classes
  # functions in column classes only to &lt;td&gt; nodes below,
  # not &lt;th&gt; nodes
  _columnClasses: (column) ->
    column.classes unless typeof column.classes is 'function'

  # responsible for &lt;tr&gt; classes
  # functions in column classes only to &lt;td&gt; nodes below,
  # not &lt;th&gt; nodes
  _rowClasses: (d) ->
    @table.rowClasses()(d) if @table.rowClasses()?

  # responsible for &lt;td&gt; classes
  # functions in column classes only to &lt;td&gt; nodes below,
  # not &lt;th&gt; nodes
  _cellClasses: (d, column) ->
    val = []

    #retrieve classes specific to the column
    val.push if column.classes?
      if typeof column.classes is 'function'
        column.classes(d)
      else
        column.classes

    val.push @utils.nestedIcons(d) if column is @columns[0]

    # retrieve classes specified in data itself
    val.push d.classes if d.classes?

    # return string split by spaces
    val.join(' ')


  # ## "Transform methods" apply optional behaviors and classes based on config

  # ### Table-level transform methods

  #
  _makeDraggable: (table) ->
    self = @

    # add space in the table header
    if table.selectAll('th.draggable-head')[0].length is 0
      table.selectAll("thead tr")
        .append('th')
          .attr('width', '15px')
          .classed('draggable-head', true)

    # add draggable &lt;td&gt;
    @enterRows.append('td')
      .classed('draggable', (d) => @utils.ourFunctor(@table.isDraggable(), d))

    @updateRows.selectAll('td.draggable').on 'mouseover', (d) ->
      self._setDragBehavior()
    .on 'mouseout', (d) ->
      self._clearDragBehavior()

  _setDragBehavior: ->
    self = @
    dragBehavior = d3.behavior.drag()
      .origin(Object)
      .on('dragstart', (d, x, y) -> self.events.dragStart(@, d, x, y))
      .on('drag',      (d, x, y) -> self.events.dragMove(@, d, x, y))
      .on('dragend',   (d, x, y) -> self.events.dragEnd(@, d, x, y))
    @updateRows.call dragBehavior

  _clearDragBehavior: ->
    self = @
    dragBehavior = d3.behavior.drag()
      .origin(Object)
      .on('dragstart', null)
      .on('drag', null)
      .on('dragend', null)
    @updateRows.call dragBehavior

  _makeDeletable: (table) ->
    # add space in the table header
    if table.selectAll('th.deletable-head')[0].length is 0
      table.selectAll("thead tr")
        .append('th')
          .attr('width', '15px')
          .classed('deletable-head', true)

    # add deletable &lt;td&gt;
    @enterRows.append('td')
      .classed('deletable', (d) => @utils.ourFunctor(@table.isDeletable(), d))
      .on 'click',
        (d) =>
          @table.onDelete()(d.id) if @utils.ourFunctor(@table.isDeletable(), d)

  #
  _makeResizable: (th) =>
    # todo: clean up contexts
    self = @
    dragBehavior = d3.behavior.drag()
      .on("drag", (a,b,c) -> self.events.resizeDrag(self,@,a,b,c))
    th.classed('resizeable',true)
      .append("div")
      .classed('resizeable-handle right', true)
      .call dragBehavior

  # ### Cell-level transform methods

  #
  _makeNested: (td) ->
    d3.select(td)
      .attr('class', (d) => @utils.nestedIcons(d))
      .on('click', (a,b,c) => @events.nestedClick(@,a,b,c))

  _makeEditable: (d, td, column) ->
    self = @

    return if _.contains ['boolean', 'select'], column.editor
    d3.select(td).classed('editable', true)
    d3.select(td).classed('calendar', true) if column.editor is 'calendar'
    # TODO: enable datepicker
    # $('.editable.calendar').datepicker()

    eventType = if column.isNested then 'dblclick' else 'click'
    d3.select(td)
      .on(eventType, (a,b,c) -> self.events.editableClick(this,a,b,c,column))

    @_makeActive(d, td, column) if d.activatedID is column.id

  _makeActive: (d, td, column) ->
    self = @
    d3.select(td)
      .classed('active', true)
      .attr('contentEditable', true)
      .on('keydown', (d) -> self.events.keydown(this, d, column))
      .on('blur', (d) -> self.events.blur(this, d, column))
      .node()
        .focus()

  _makeChanged: (d, td, column) ->
    if d.changedID and (i = d.changedID.indexOf(column.id)) isnt -1
      d3.select(td).classed('changed', true)
      d.changedID.splice i, 1

  _makeSelect: (d, td, column) ->
    select = d3.select(td)
      .html('<select class="expand-select"></select>')
      .select('.expand-select')

    # add current value
    select.append('option')
      .style('cursor', 'pointer')
      .text(d[column.id])

    # add other options
    group = select.append('optgroup').style('cursor', 'pointer')
    _.each _.without(column.selectOptions, d[column.id]), (item) =>
      group.append('option')
        .style('cursor', 'pointer')
        .text(item)

    select.on('change', (a, b, c) => @events.selectClick(@, a, b, c, column))

  _makeButton: (d, td, column) ->
    select = d3.select(td)
      .html("<input type='button' value='#{ column.label }' />")
      .on('click', (a, b, c) => @events.buttonClick(@, a, b, c, column))

  _makeBoolean: (d, td, column) ->
    d3.select(td)
      .classed('boolean-true', d[column.id])
      .classed('boolean-false', not d[column.id])
      .on('click', (a, b, c) => @events.toggleBoolean(@, a, b, c, column))

  _addShowCount: (d, td, column) ->
    count = d.values?.length or d._values?.length
    d3.select(td).append('span')
      .classed('childrenCount', true)
      .text (d) -> if count then '(' + count + ')' else ''

