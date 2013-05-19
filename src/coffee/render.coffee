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
    @headRows = @table.headRows()

  update: ->
    @table.isInRender = true
    @selection.call (selection) =>
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
      .classed(@table.tableClassName, true)
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

    # create table header
    thead = tableObject.selectAll('thead')
      .data((d)->d)
      .enter()
        .append('thead')

    if !@headRows
      # create table header row
      theadRow = thead
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
    else
      # create table header row
      theadRow = thead.selectAll("thead")
        .data(@headRows)
        .enter()
          .append("tr")
            .attr("class", (d) -> d.headClasses)

      # append a &lt;th&gt; for each column
      th = theadRow.selectAll("th")
        .data((row, i) -> row.col)
        .enter()
          .append("th")
            .text((d) ->
              d.classes += ' ' + 'underline' unless d.label
              d.label)
            .attr("ref", (d,i) -> i)
            .attr("class", (d) => @_columnClasses(d))
            .style('width', (d) -> d.width)
          .transition()

    # for now, either all columns are resizable or none, set in table config
    allTh = theadRow
      .filter((d) -> true unless d.headClasses)
      .selectAll("th")
    @_makeResizable(allTh) if @table.isResizable()
    sortable = allTh.filter (d)->
      d.isSortable
    @_makeSortable(sortable)
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
      text = (d) ->
        if column.timeSeries? and d.period? and d.dataValue?
          index = d.period.indexOf(column.id)
          if column.format
            column.format d.dataValue[index]
          else
            d.dataValue[index]
        else if column.format
          column.format d
        else
          d[column.id] or '-'

      @enterRows.append('td')
        .attr('meta-key', column.id)
        .attr('class', (d) => @_cellClasses(d, column))
        .html(text)
        .each (d, i) -> self._renderCell(column, d, @)

  _renderUpdateRows: ->
    self = @
    @updateRows.selectAll('td').each (d, i) ->
      self._renderCell(self.columns[i], d, @) if self.columns[i]?

  _renderCell: (column, d, td) ->
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
      .on("drag", -> self.events.resizeDrag(@))
    handlers = th.classed('resizeable',true)
      .append("div")
      .classed('resizeable-handle right', true)
      .call dragBehavior
    #remove last handle
    removable = handlers[0] and
      handlers[0][handlers[0].length-1] and
      handlers[0][handlers[0].length-1].remove
    if removable
      handlers[0][handlers[0].length-1].remove()

  _makeSortable: (allTh)->
    self = @
    allTh.classed('sortable',true)
      .append("div")
      .classed('sortable-handle', true)
    sorted = allTh.filter (column)->
      column.desc?
    if sorted[0] and sorted[0].length > 0
      desc = sorted.data()[0].desc
      sorted.classed('sorted-asc',desc)
      sorted.classed('sorted-desc',!desc)
    allTh.on 'click', (a,b,c)->
      self.events.toggleSort @,a,b,c

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

    if d.changed is column.id
        d3.select(td).classed('changed', true)

    agent = navigator.userAgent.toLowerCase()
    if agent.indexOf('iphone') >= 0 or agent.indexOf('ipad') >= 0
      eventType = 'touchend'
      d3.select(td)
        .on(eventType, (a,b,c) -> self.events.doubleTap(@,a,b,c,column))
    else
      eventType = 'dblclick'
      d3.select(td)
        .on(eventType, (a,b,c) -> self.events.editableClick(@,a,b,c,column))

    if d.activatedID is column.id.toString()
      @_makeActive(d, td, column)
    else
      @_makeInactive(td)

  _makeActive: (d, td, column) ->
    self = @

    _text = (d) ->
      if _.has(column, 'timeSeries')
        d.dataValue[_.indexOf(d.period, column.id)] or '-'
      else
        d[column.id] or '-'

    d3.select(td)
      .classed('active', true)
      .text(_text)
      .attr('contentEditable', true)
      .on('keydown', (d) -> self.events.keydown(this, d, column))
      .on('blur', (d) -> self.events.blur(this, d, column))
      .node()
        .focus()

  _makeInactive: (node) ->
    self = @
    d3.select(node)
      .classed('active', false)
#      .classed('editable', true)
#      .classed('changed', true)
      .attr('contentEditable', false)

  _makeChanged: (d, td, column) ->
    if d.changedID and (i = d.changedID.indexOf(column.id)) isnt -1
      d.changedID.splice i, 1

  _makeSelect: (d, td, column) ->
    options = @utils.ourFunctor(column.selectOptions, d)

    select = d3.select(td)
      .html('<select class="expand-select"></select>')
      .select('.expand-select')

    # add current value
    select.append('option')
      .style('cursor', 'pointer')
      .text(d[column.id])

    # add other options
    group = select.append('optgroup').style('cursor', 'pointer')
    _.each _.without(options, d[column.id]), (item) =>
      group.append('option')
        .style('cursor', 'pointer')
        .text(item)

    select.on('change', (a, b, c) => @events.selectClick(@, a, b, c, column))

  _makeButton: (d, td, column) ->
    classes = 'btn btn-mini btn-primary'
    html = "<input type='button' value='#{column.label}' class='#{classes}' />"
    select = d3.select(td)
      .html(html)
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
