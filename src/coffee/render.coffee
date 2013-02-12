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

  # responsible for <table> and contents
  #
  # calls renderHead() for <thead> and contents
  # calls renderBody() for <tbody and contents
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
    @_makeDeletable(@tableObject) unless @table.isDeletable() is false

  _buildData: ->
    @data[0] = id: @table.noData unless @data[0]
    @tree = d3.layout.tree().children (d) -> d.values
    @nodes = @tree.nodes(@data[0])

    # calculate number of columns
    depth = d3.max(@nodes, (node) -> node.depth)
    @tree.size [@table.height, depth * @table.childIndent]

  # responsible for <thead> and contents
  _renderHead: (tableObject) ->
    self = @

    # create table header and row
    theadRow = tableObject.selectAll("thead")
      .data((d) -> d)
      .enter()
        .append("thead")
        .append("tr")

    # append a <th> for each column
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

    # todo: move this down
    if @table.is('reorder_dragging')
      theadRow.append('th').attr('width', '10px')

    @

  # responsible for <tbody> and contents
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
      @updateRows.on key, (d) -> self.table.dispatch.elementClick
        row: @
        data: d
        pos: [d.x, d.y]

    _.each events, (value, key) -> addEvent(key, value)

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

    # columns added before data columns
    @draggable() if @table.is 'hierarchy_dragging'
    @reorder_draggable() if @table.is 'reorder_dragging'

    d3.select(@enterRows[0][0]).style("display", "none") if @enterRows[0][0]

    @_renderEnterRows()
    @_renderUpdateRows()

  _renderEnterRows: ->
    self = @
    @columns.forEach (column, column_index) =>
      @enterRows.append('td')
        .each (d, i) -> self._renderCell(column, d, @)

  _renderUpdateRows: ->
    self = @
    @updateRows.selectAll('td')
      .each (d, i) -> self._renderCell(self.columns[i], d, @)

  _renderCell: (column, d, td) ->
    d3.select(td)
      .attr('meta-key', column.key)
      .attr('class', (d) => @_cellClasses(d, column))
      .text((d) -> d[column.key] or '-')

    @_makeNested(td) if @_ourFunctor(column.isNested, d)
    @_makeEditable(d, td, column) if @_ourFunctor(column.isEditable, d)
    @_makeChanged(d, td, column)
    @_addShowCount(d, td, column) if column.showCount

  _toggleBoolean: (context) ->
    if d3.select(context).attr('class') is 'editable boolean-false'
      d[column.key] = 'true'
      d3.select(context).attr('class', 'editable boolean-true')
    else
      d[column.key] = 'false'
      d3.select(context).attr('class', 'editable boolean-false')

  # similar in spirit to d3.functor()
  # https://github.com/mbostock/d3/wiki/Internals
  #
  # TODO: move to utils
  _ourFunctor: (attr, element) ->
    if typeof attr is 'function'
      attr(element)
    else
      attr

  # ## "Class methods" (tongue in cheek) define classes to be applied to tags
  # Note: There are other methods that add/remove classes but these are the
  # primary points of contact

  # responsible for <th> classes
  # functions in column classes only to <td> nodes below, not <th> nodes
  _columnClasses: (column) ->
    column.classes unless typeof column.classes is 'function'

  # responsible for <tr> classes
  # functions in column classes only to <td> nodes below, not <th> nodes
  _rowClasses: (d) ->
    @table.rowClasses()(d) if @table.rowClasses()?

  # responsible for <td> classes
  # functions in column classes only to <td> nodes below, not <th> nodes
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

  selectBox: (node, d, column) ->
    self = @
    d3.select(node).classed('active', true)
    select = d3.select(node)
      .html('<select class="expand-select"></select>')
      .select('.expand-select')
    if @val?
      option = select.append('option')
        .style('cursor', 'pointer')
        .text(@val)
        .style('display', 'none')
    for label in d[column.key].label
      if typeof label is 'string'
        option = select.append('option').text(label)
      else
        for options in label
          if typeof options is 'string'
            optgroup = select.append('optgroup')
              .style('cursor', 'pointer')
              .attr('label', options)
          else
            for index in options
              option = optgroup.append('option')
                .style('cursor', 'pointer')
                .text(index)
    select.on 'click', (d) ->
      select.remove()
      d3.select(node).append('span').text(d3.event.target.value)
      self.val = d3.event.target.value
      self.update()

  _makeResizable: (th) =>
    self = @
    dragBehavior = d3.behavior.drag()
      .on("drag", (a,b,c) -> self.events.resizeDrag(self,@,a,b,c))
    th.classed('resizeable',true)
      .append("div")
      .classed('resizeable-handle right', true)
      .call dragBehavior

  _makeDeletable: (table) =>
    # add space in the table header
    table.selectAll("thead tr")
      .append('th')
        .attr('width', '15px')

    # add deletable <td>
    @updateRows.append('td')
      .classed('deletable', (d) => @_ourFunctor(@table.isDeletable(), d))
      .on 'click',
        (d) => @table.onDelete()(d.id) if @_ourFunctor(@table.isDeletable(), d)

  _makeNested: (td) =>
    self = @
    d3.select(td)
      .attr('class', (d) -> self.utils.nestedIcons(d))
      .on('click', (a,b,c) -> self.events.nestedClick(this,a,b,c))

  _makeEditable: (d, td, column) ->
    self = @

    d3.select(td).classed('editable', true)

    eventType = if column.isNested then 'dblclick' else 'click'
    d3.select(td)
      .on(eventType, (a,b,c) -> self.events.editable(this,a,b,c,column))

    if d.activatedID is column.key
      if d[column.key].classes is 'select'
        @selectBox(td, d, column)
      else
        d3.select(td)
          .classed('active', true)
          .attr('contentEditable', true)
          .on('keydown', (d) -> self.events.keydown(this, d, column))
          .on('blur', (d) -> self.events.blur(this, d, column))
          .node()
            .focus()
    else if d.changedID and d.changedID.indexOf(column.key) isnt -1
      d3.select(td).classed('changed', true)

  _makeChanged: (d, td, column) ->
    if d.changedID and (i = d.changedID.indexOf(column.key)) isnt -1
      d3.select(td).classed('changed', true)
      d.changedID.splice i, 1

  _addShowCount: (d, td, column) ->
    count = d.values?.length or d._values?.length
    d3.select(td).append('span')
      .classed('childrenCount', true)
      .text (d) -> if count then '(' + count + ')' else ''

  draggable: ->
    self = @
    dragbehavior = d3.behavior.drag()
      .origin(Object)
      .on("dragstart", (a,b,c) -> self.events.dragstart(this,a,b,c))
      .on("drag",      (a,b,c) -> self.events.dragmove(this,a,b,c))
      .on("dragend",   (a,b,c) -> self.events.dragend(this,a,b,c))
    @updateRows.call dragbehavior

  reorder_draggable: ->
    self = @
    @updateRows.insert("td").classed('draggable', true)
    dragbehavior = d3.behavior.drag()
      .origin(Object)
      .on("dragstart", (a,b,c) -> self.events.reordragstart(this,a,b,c))
      .on("dragend",   (a,b,c) -> self.events.reordragend(this,a,b,c))
    @updateRows.call dragbehavior

