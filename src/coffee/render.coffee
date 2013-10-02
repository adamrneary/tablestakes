window.TableStakesLib = {} unless window.TableStakesLib
class window.TableStakesLib.Core

  # Constructor, getter, and setter methods
  # ---------------------------------------
  
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

  # Building the base DOM elements
  # ------------------------------

  # Responsible for &lt;table&gt; and contents
  #
  # Calls renderHead() for &lt;thead&gt; and contents
  # Calls renderBody() for &lt;tbody&gt; and contents
  render: ->

    # First get your data
    @_buildData()
    
    # Then build the table itself
    wrap = d3.select(@table.el())
      .selectAll("div")
      .data([[@nodes]])
    wrapEnter = wrap.enter().append("div")
    @tableEnter = wrapEnter.append("table")
    @tableObject = wrap.select("table")
      .classed(@table.tableClassName, true)

    # Add header and body
    @_renderHead(@tableObject) if @table.header
    @_renderBody(@tableObject)
    
    # Apply table-level config
    @_makeDraggable(@tableObject) unless @table.isDraggable() is false
    @_makeDeletable(@tableObject) unless @table.isDeletable() is false
    @_makeScrollable(@tableObject) if _.isNumber(@table.height())

  # TODO: This method needs documentation
  _buildData: ->
    @data[0] = id: @table.noData unless @data[0]
    @tree = d3.layout.tree().children (d) -> d.values
    @nodes = @tree.nodes(@data[0])

    # Calculate number of columns
    depth = d3.max(@nodes, (node) -> node.depth)
    @tree.size [@table.height, depth * @table.childIndent]

  # Responsible for &lt;thead&gt; and contents
  _renderHead: (tableObject) ->
    # Create table header
    thead = tableObject.selectAll('thead')
      .data((d) -> d)
      .enter()
        .append('thead')

    if !@headRows # TODO: What does this line do?
      # Create table header row
      theadRow = thead
        .append("tr")

      # Append a &lt;th&gt; for each column
      th = theadRow.selectAll("th")
        .data(@columns)
        .enter()
          .append("th")
            .attr("ref", (d,i) -> i)
            .attr("class", (d) => @_columnClasses(d))
            .style('width', (d) -> d.width)
            .append('div')
              .text((d) -> d.label)
    else
      # Create table header row
      theadRow = thead.selectAll("thead")
        .data(@headRows)
        .enter()
          .append("tr")
            .attr("class", (d) -> d.headClasses)

      # Append a &lt;th&gt; for each column
      th = theadRow.selectAll("th")
        .data((row, i) -> row.col)
        .enter()
          .append("th")
            .attr("ref", (d,i) -> i)
            .attr("class", (d) =>
              @_columnClasses(d) + ' underline')
            .style('width', (d) -> d.width)
            .append('div')
              .text((d) -> d.label)

    # Apply header-level config
    allTh = theadRow
      .filter((d) -> true unless d.headClasses)
      .selectAll("th")

    # Individual columns can be made sortable, or all, or none
    sortable = allTh.filter (d) -> d.isSortable or d.sorted?
    @_makeSortable(sortable)

    # For now, either all columns are resizable or none, set in table config
    @_makeResizable(allTh) if @table.isResizable() and not _.isNumber(@table.get('height'))
    
    # return @ to make the method chainable (TODO: but why? we can prob delete?)
    @

  # Responsible for &lt;tbody&gt; and contents
  _renderBody: (tableObject) ->
    # render the body itself
    @tbody = tableObject.selectAll("tbody").data((d) -> d)
    @tbody.enter().append "tbody"
    
    # Create objects that can be chained against for each row
    @rows = @tbody.selectAll("tr")
      .data(((d) -> d), (d) -> d.id)
    @_enterRows()
    @_updateRows()
    @_exitRows()

    # Hide the first row (TODO: but why?)
    d3.select(@enterRows[0][0])
      .style("display", "none") if @enterRows[0][0]

    # Now render the rows themselves
    @_renderEnterRows()
    @_renderUpdateRows()

  # Creates an object that can be chained against for rows that are entering.
  #
  # See D3 documentation for the logic behind thinking in joins:
  # http://bost.ocks.org/mike/join/
  _enterRows: ->
    @enterRows = @rows
      .enter()
        .append("tr")
        .attr("class", (d) => @_rowClasses(d))

  # Creates an object that can be chained against for rows that are being updated.
  # Per D3 convention, this *includes* entering and existing rows not exiting.
  #
  # See D3 documentation for the logic behind thinking in joins:
  # http://bost.ocks.org/mike/join/
  _updateRows: ->
    @updateRows = @rows.order()
    @_addRowEventHandling()
    @updateRows.select('.expandable')
      .classed('folded', @utils.folded)

  # Creates an object that can be chained against for rows that are exiting.
  #
  # See D3 documentation for the logic behind thinking in joins:
  # http://bost.ocks.org/mike/join/
  _exitRows: ->
    @rows
      .exit()
        .remove()

  # This method binds basic event handling at the row level so that methods in
  # events.coffee can handle them.
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


  # Responsible for rendering new rows
  _renderEnterRows: ->
    self = @
    
    # TODO: I am skeptical about the need for this forEach as opposed to using 
    # a join correctly. Perhaps in the future we will have a D3 maniac at our
    # disposal who can help with this line.
    @columns.forEach (column, column_index) =>
      
      # Determine the text to be included in the cell
      text = (d) ->
        if column.timeSeries? and d.period? and d.dataValue?
          index = d.period.indexOf(column.id)
          if column.format
            cell = _.clone d
            cell.dataValue = d.dataValue[index]
            column.format cell, column
          else
            d.dataValue[index]
        else if column.format
          column.format d, column
        else
          d[column.id] or '-'

      @enterRows.append('td')
        
        # add cell classes
        .attr('class', (d) => @_cellClasses(d, column))
        
        # add a column id
        .attr('meta-key', column.id)

        # include text in a div due to IE problems
        .append('div') 
          .html(text).each (d, i) -> 
            
            # TODO: Do we really need this? I believe _renderUpdateRows
            # achieves this for every cell, including entering cells
            self._renderCell(column, d, @)

  # Responsible for updating existing rows
  _renderUpdateRows: ->
    self = @
    @updateRows.selectAll('div').each (d, i) ->
      self._renderCell(self.columns[i], d, @) if self.columns[i]?

  # Responsible for rendering the cell itself (finally!)
  #
  # Note: At this point, the text of the cell is already populated. Here we're
  # more concerned with classes and behaviors
  _renderCell: (column, d, div) ->
    isEditable = @utils.ourFunctor(column.isEditable, d, column)
    @_makeNested(div) if @utils.ourFunctor(column.isNested, d)
    @_makeEditable(d, div, column) if isEditable
    @_makeChanged(d, div, column)
    @_makeBoolean(d, div, column) if column.editor is 'boolean' and isEditable
    @_makeSelect(d, div, column) if column.editor is 'select' and isEditable
    @_makeButton(d, div, column) if column.editor is 'button' and isEditable
    @_addShowCount(d, div, column) if column.showCount

  # "Class methods" (tongue in cheek) define classes to be applied to tags
  # ----------------------------------------------------------------------
  #
  # Note: There are other methods that add/remove classes but these are the
  # primary points of contact

  # Responsible for &lt;th&gt; classes
  # functions in column classes only to &lt;td&gt; nodes below,
  # not &lt;th&gt; nodes
  _columnClasses: (column) ->
    if _.isFunction(column.classes)
      column.classes({}, column) || ''
    else
      column.classes || ''

  # Responsible for &lt;tr&gt; classes
  # functions in column classes only to &lt;td&gt; nodes below,
  # not &lt;th&gt; nodes
  _rowClasses: (d) ->
    @table.rowClasses()(d) if @table.rowClasses()?

  # Responsible for &lt;td&gt; classes
  # functions in column classes only to &lt;td&gt; nodes below,
  # not &lt;th&gt; nodes
  _cellClasses: (d, column) ->
    val = []

    # Retrieve classes specific to the column
    val.push if column.classes?
      if typeof column.classes is 'function'
        column.classes(d, column)
      else
        column.classes

    val.push @utils.nestedIcons(d) if column.isNested

    # Retrieve classes specified in data itself
    val.push d.classes if d.classes?

    # Return string split by spaces
    val.join(' ')


  # "Transform methods" apply optional behaviors and classes based on config
  # ------------------------------------------------------------------------
  
  # Table-level transform methods
  # =============================

  # TODO: this method needs documentation
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
      .append('div')

    @updateRows.selectAll('td.draggable').on 'mouseover', (d) ->
      self._setDragBehavior()
    .on 'mouseout', (d) ->
      self._clearDragBehavior()

  # TODO: this method needs documentation
  _setDragBehavior: ->
    self = @
    dragBehavior = d3.behavior.drag()
      .origin(Object)
      .on('dragstart', (d, x, y) -> self.events.dragStart(@, d, x, y))
      .on('drag',      (d, x, y) -> self.events.dragMove(@, d, x, y))
      .on('dragend',   (d, x, y) -> self.events.dragEnd(@, d, x, y))
    @updateRows.call dragBehavior

  # TODO: this method needs documentation
  _clearDragBehavior: ->
    self = @
    dragBehavior = d3.behavior.drag()
      .origin(Object)
      .on('dragstart', null)
      .on('drag', null)
      .on('dragend', null)
    @updateRows.call dragBehavior

  # TODO: this method needs documentation
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
      .append('div')
        .on 'click',
          (d) =>
            @table.onDelete()(d.id) if @utils.ourFunctor(@table.isDeletable(), d)

  # TODO: this method needs documentation
  _makeResizable: (allTd) =>
    # todo: clean up contexts
    self = @
    length = _.size(allTd[0])

    dragBehavior = d3.behavior.drag()
      .on("drag", -> self.events.resizeDrag(@))

    allTd.classed('resizable',true)

    first = allTd.filter((d, i) -> i > 0).selectAll("div")
    last = allTd.filter((d, i) -> i+1 < length).selectAll("div")

    first.insert("div")
      .classed("resizable-handle", true)
      .classed("left", true)
      .call dragBehavior

    last.append("div")
      .classed('resizable-handle', true)
      .classed('right', true)
      .call dragBehavior
    
  # TODO: this method needs documentation
  _makeSortable: (allTd)->
    self = @

    allTd.classed('sortable',true)
      .append("div")
        .classed('sortable-handle', true)

    sorted = allTd.filter (column)->
      column.asc?
    if sorted[0] and sorted[0].length > 0
      asc = sorted.data()[0].asc
      sorted.classed('sorted-asc',asc)
      sorted.classed('sorted-desc',!asc)
    allTd.on 'click', (a,b,c)->
      self.events.toggleSort @,a,b,c

  _makeScrollable: (tableObject)->
    # set width attr to thead > td, th
    _.each($('.tablestakes thead td'), (d) ->
      $(d).width($(d).width()))
    _.each($('.tablestakes thead th'), (d) ->
      $(d).width($(d).width()))

    # set width attr to tbody > td, th
    _.each($('.tablestakes tbody td'), (d) ->
      $(d).width($(d).width()))
    _.each($('.tablestakes tbody th'), (d) ->
      $(d).width($(d).width()))

    tableObject.classed("scrollable", true)
    tableObject.select('tbody').style("height", "#{@table.height()}px")
    @table.isResizable(false)

  # Cell-level transform methods
  # ============================

  # TODO: this method needs documentation
  _makeNested: (div) ->
    d3.select(div.parentNode).classed('collapsible', false)
    d3.select(div.parentNode).classed('expandable', false)
    appliedClasses = d3.select(div.parentNode).attr('class')
    d3.select(div.parentNode)
      .attr('class', (d) =>
        appliedClasses += ' ' + @utils.nestedIcons(d)
        _.uniq(appliedClasses.split(' ')).join(' ')
      )
      .on('click', (a,b,c) => @events.nestedClick(@,a,b,c))

  # TODO: this method needs documentation
  _makeEditable: (d, div, column) ->
    self = @

    return if _.contains ['boolean', 'select'], column.editor
    d3.select(div.parentNode).classed('editable', true)
    d3.select(div.parentNode).classed('calendar', true) if column.editor is 'calendar'
    # TODO: enable datepicker
    # $('.editable.calendar').datepicker()

    if d.changed is column.id
      d3.select(div.parentNode).classed('changed', true)

    agent = navigator.userAgent.toLowerCase()
    if agent.indexOf('iphone') >= 0 or agent.indexOf('ipad') >= 0
      eventType = 'touchend'
      d3.select(div)
        .on(eventType, (a,b,c) -> self.events.doubleTap(@,a,b,c,column))
    else
      eventType = 'dblclick'
      d3.select(div)
        .on(eventType, (a,b,c) -> self.events.editableClick(@,a,b,c,column))

    if d.activatedID is column.id.toString()
      @_makeActive(d, div, column)
    else
      @_makeInactive(div)

  # TODO: this method needs documentation
  _makeActive: (d, div, column) ->
    self = @

    getValue = (d) ->
      if column.timeSeries
        if d.dataValue and d.period
          index = d.period.indexOf(column.id)
          cell = _.clone d
          cell.dataValue = d.dataValue[index]
          cell
        else
          ""
      else
        d

    getFormattedValue = (d) ->
      value = d.dataValue || d[column.id]
      formattedValue = if column.format
        column.format(d, column)
      else
        if column.timeSeries then d.dataValue else d[column.id]

      # parse formattedValue for numeral().format('$0.[00]a')
      if _.last(formattedValue) in ["k", "b", "m", "t", "K", "B", "M", "T"]
        value
      else
        formattedValue

    _text = (d) ->
      value = getValue(d)
      getFormattedValue(value)

    # TODO: handle .calendar input
    d3.select(div.parentNode).classed('active', true)
    d3.select(div)
      .text(_text)
      .attr('contentEditable', true)
      .on('keydown', (d) -> self.events.keydown(this, d, column))
      .on('blur', (d) -> self.events.blur(this, d, column))
      .node()
        .focus()

  # TODO: this method needs documentation
  _makeInactive: (node) ->
    self = @
    d3.select(node.parentNode)
      .classed('active', false)
    d3.select(node)
      .attr('contentEditable', false)

  # TODO: this method needs documentation
  _makeChanged: (d, div, column) ->
    if d.changedID and (i = d.changedID.indexOf(column.id)) isnt -1
      d.changedID.splice i, 1

  # TODO: this method needs documentation
  _makeSelect: (d, div, column) ->
    options = @utils.ourFunctor(column.selectOptions, d)
    d3.select(div.parentNode)
      .classed("select", true)

    select = d3.select(div)
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

  # TODO: this method needs documentation
  _makeButton: (d, div, column) ->
    classes = 'btn btn-mini btn-primary'
    html = "<input type='button' value='#{column.label}' class='#{classes}' />"
    select = d3.select(div)
      .html(html)
      .on('click', (a, b, c) => @events.buttonClick(@, a, b, c, column))

  # TODO: this method needs documentation
  _makeBoolean: (d, div, column) ->
    d3.select(div.parentNode)
      .classed('boolean-true', d[column.id])
      .classed('boolean-false', not d[column.id])
      .on('click', (a, b, c) => @events.toggleBoolean(@, a, b, c, column))

  # TODO: this method needs documentation
  _addShowCount: (d, div, column) ->
    count = d.values?.length or d._values?.length
    d3.select(div).append('span')
      .classed('childrenCount', true)
      .text (d) -> if count then '(' + count + ')' else ''
