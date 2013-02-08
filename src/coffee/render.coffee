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
    @data[0] = id: @table.noData unless @data[0]
    @tree = d3.layout.tree().children (d) -> d.values
    @nodes = @tree.nodes(@data[0])

    wrap = d3.select(@table.el())
      .selectAll("div")
      .data([[@nodes]])
    wrapEnter = wrap.enter().append("div")
    @tableEnter = wrapEnter.append("table")
    @tableObject = wrap.select("table")
      .classed(@table.tableClassName,true)
      .attr("style","table-layout:fixed;")

    @_renderHead(@tableObject) if @table.header
    @_renderBody(@tableObject)
  
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

    # add space for optional functional columns
    unless @table.isDeletable() is false
      theadRow.append('th').attr('width', '15px')
    if @table.is('reorder_dragging')
      theadRow.append('th').attr('width', '10px')

    @
  
  _renderBody: (tableObject) ->
    self = @
    tbody = @tableObject.selectAll("tbody").data((d) -> d)
    tbody.enter().append "tbody"

    # calculate number of columns
    depth = d3.max(@nodes, (node) -> node.depth)
    @tree.size [@table.height, depth * @table.childIndent]

    i = 0
    node = tbody.selectAll("tr").data((d) ->
      d
    , (d) ->
      d.id or (d.id is ++i)
    )

    @nodeEnter = node
      .enter()
        .append("tr")
        .classed(self._rowClasses(), true)

    # hide marker row
    d3.select(@nodeEnter[0][0]).style("display", "none") if @nodeEnter[0][0]

    # columns added before data columns
    @draggable() if @table.is 'hierarchy_dragging'
    @reorder_draggable() if @table.is 'reorder_dragging'

    # data columns
    @columns.forEach (column, index) =>
      @_renderColumn column, index, node

    # columns added after data columns
    @nodeEnter.append('td')
      .classed('deletable', (d) =>
        @confirmTableElementAttribute(@table.isDeletable(), d)
      )
      .on('click', (d) =>
        if @confirmTableElementAttribute(@table.isDeletable(), d)
          @table.onDelete()(d.id)
      )

    node
      .order()
      .on("click", (d) -> self.table.dispatch.elementClick(
        row: this
        data: d
        pos: [d.x, d.y]
      ))
      .on("dblclick", (d) -> self.table.dispatch.elementDblclick(
        row: this
        data: d
        pos: [d.x, d.y]
      ))
      .on("mouseover", (d) -> self.table.dispatch.elementMouseover(
        row: this
        data: d
        pos: [d.x, d.y]
      ))
      .on("mouseout", (d) -> self.table.dispatch.elementMouseout(
        row: this
        data: d
        pos: [d.x, d.y]
      ))
      .exit().remove()

    node.select(".expandable").classed "folded", @utils.folded


  _renderColumn: (column, index, node) ->
    self = @
    column_td = @nodeEnter.append("td")
      .attr("meta-key",column.key)
      .classed(self._cellClasses(), true)

    @_renderFirstColumn(column, column_td) if index is 0
    @_renderNodes(column, column_td)
    @_appendCount(column_td) if column.showCount

  _renderFirstColumn: (column, column_td) =>
    column_td.attr("ref", column.key)
    column_td.attr('class', (d) => @utils.icon (d))

    if @table.is('nested')
      @nested column_td
    else if @.table.is('nested-filter')
      filter = @.table.get('nested-filter')
      @nested column_td if filter(column)

    if @table.is('nested')
      @nested column_td
    else if @table.is('nested-filter')
      filter = @table.get('nested-filter')
      @nested column_td if filter(column)

  _appendCount: (column_td) ->
    column_td.append("span")
      .classed("childrenCount",true)
      .text (d) ->
        count = d.values?.length or d._values?.length
        if count then "(" + count + ")" else ""

  _renderNodes: (column, column_td) ->
    self = @
    column_td.each (td, i) ->
      if td[column.key] and td[column.key].classes?
        classes = td[column.key].classes.split(' ')
        for _class in classes
          d3.select(this).classed _class,true
        columnClass = td[column.key].classes

      if columnClass?
        d3.select(this).classed(columnClass, true)
      if column.classes?
        d3.select(this).classed(column.classes, true)

      if column.classes is 'boolean' or columnClass is 'boolean'
        span = d3.select(this).attr('class', (d) ->
          if d[column.key]
            if typeof d[column.key] is 'string'
              truthies = ['true','y','Y','yes','Yes','+','good','ok']
              if _.includes(truthies, d[column.key])
                'editable boolean-true'
              else
                'editable boolean-false'
            else
              if d[column.key].label is 'true'
                'editable boolean-true'
              else
                'editable boolean-false').style('display', 'table-cell'
        ).on "click", @_toggleBoolean(this)
      else if columnClass is 'select'
        select = d3.select(this)
          .classed('active', true)
          .html('<select class="expand-select"></select>')
          .select('.expand-select')
        for label in td[column.key].label
          if typeof label is 'string'
            option = select.append('option').text(label)
          else
            for options in label
              if typeof options is 'string'
                optgroup = select.append('optgroup').attr('label', options)
              else
                for index in options
                  option = optgroup.append('option').text(index)
      else
        span = d3.select(this)
          .append("span")
          .attr("class", d3.functor(column.classes))
        innerSpan = span.append('span').text (d) ->
          if column.format
            column.format(d)
          else
            if d[column.key]
              if typeof d[column.key] is 'string'
                d[column.key]
              else if typeof d[column.key].label is 'string'
                d[column.key].label
            else
              "-"
      if td.changedID and (i = td.changedID.indexOf(column.key)) isnt -1
        d3.select(this).classed 'changed'
        td.changedID.splice i, 1

      if self.confirmTableElementAttribute column.isEditable, td
        self.editable column_td, td, this, column

  _toggleBoolean: (context) ->
    if d3.select(context).attr('class') is 'editable boolean-false'
      d[column.key] = 'true'
      d3.select(context).attr('class', 'editable boolean-true')
    else
      d[column.key] = 'false'
      d3.select(context).attr('class', 'editable boolean-false')

  confirmTableElementAttribute: (attr, element) ->
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
    "columnClasses"
    # if column.classes?
    #   column.classes unless typeof column.classes is 'function'

  # responsible for <tr> classes
  # functions in column classes only to <td> nodes below, not <th> nodes
  _rowClasses: (column) ->
    "rowClasses"
    # if column.classes?
    #   column.classes unless typeof column.classes is 'function'

  # responsible for <td> classes
  # functions in column classes only to <td> nodes below, not <th> nodes
  _cellClasses: (column) ->
    "cellClasses"
    # if column.classes?
    #   column.classes unless typeof column.classes is 'function'
      #       (d) =>
      #         row_classes = ""
      #         row_classes = d.classes if typeof d.classes != "undefined"
      #         return col_classes + " " + row_classes
      # )
      # col_classes = ""
      # col_classes += column.classes if typeof column.classes != "undefined"


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

  editable: (td, d, node, column) ->
    self = @
    td.classed 'editable'
    if @table.is 'nested'
      event = 'dblclick'
    else
      event = 'click'
    td.on event, (a,b,c)->
      self.events.editable this,a,b,c,column
    if d.activatedID == column.key
      if d[column.key].classes is 'select'
        @selectBox(node, d, column)
      else
        d3.select(node).classed('active', true).attr('contentEditable', true)
        .on "keydown", (d)-> self.events.keydown this, d, column
        .on "blur", (d) -> self.events.blur this, d, column
        .node().focus()
    else if d.changedID and d.changedID.indexOf(column.key) isnt -1
      d3.select(node).classed 'changed',true
        
  # ## "Event methods" add classes and event handling to d3 selections
  
  _makeResizable: (th) =>
    self = @
    dragBehavior = d3.behavior.drag()
      .on("drag", (a,b,c) -> self.events.resizeDrag(self,@,a,b,c))
    th.classed('resizeable',true)
      .append("div")
      .classed('resizeable-handle right', true)
      .call dragBehavior

  draggable: ->
    self = @
    dragbehavior = d3.behavior.drag()
      .origin(Object)
      .on("dragstart", (a,b,c) -> self.events.dragstart(this,a,b,c))
      .on("drag",      (a,b,c) -> self.events.dragmove(this,a,b,c))
      .on("dragend",   (a,b,c) -> self.events.dragend(this,a,b,c))
    @nodeEnter.call dragbehavior

  reorder_draggable: ->
    self = @
    @nodeEnter.insert("td").classed('draggable', true)
    dragbehavior = d3.behavior.drag()
      .origin(Object)
      .on("dragstart", (a,b,c) -> self.events.reordragstart(this,a,b,c))
      .on("dragend",   (a,b,c) -> self.events.reordragend(this,a,b,c))
    @nodeEnter.call dragbehavior

  nested: (nodeName) ->
    self = @
    nodeName.on("click", (a,b,c) -> self.events.click(this,a,b,c))
