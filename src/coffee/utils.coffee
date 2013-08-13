window.TableStakesLib = {} unless window.TableStakesLib
class window.TableStakesLib.Utils

  constructor: (options) ->
    @core = options.core

  getCurrentColumnIndex: (id) ->
    currentindex = @core.columns.length
    for col, i in @core.columns
      if col.id == id
        currentindex = i
        break
    currentindex

  findEditableColumn: (d, currentIndex, isNext) ->
    if isNext
      condition = currentIndex < @core.columns.length
      nextIndex = currentIndex + 1
    else
      condition = currentIndex >= 0
      nextIndex = currentIndex - 1
    if condition
      column = @core.columns[currentIndex]
      if column.isEditable
        if typeof column.isEditable is 'boolean'
          return currentIndex
        else if column.isEditable(d,column)
          return currentIndex
        else
          @findEditableColumn d, nextIndex, isNext
      else
        @findEditableColumn d, nextIndex, isNext
    else
      return null

  findEditableCell: (d, column, isNext) ->
    if isNext
      node = @core.utils.findNextNode d
    else
      node = @core.utils.findPrevNode d
    if node?
      if column.isEditable
        isBoolean = typeof column.isEditable is 'boolean'
        if isBoolean or column.isEditable(node,column)
          return node
        else
          @findEditableCell node,column,isNext

  findNextNode: (d) ->
    nextNodeID = null
    for leaf, i in @core.nodes
      if leaf._id == d._id
        if @core.nodes.length != i + 1
          nextNodeID = @core.nodes[i + 1]._id
        break
    return null if nextNodeID is null
    idPath = nextNodeID.split "_"
    root = @core.data[0]
    root = root.values[parseInt(idPath[i])] for i in [1..idPath.length-1]
    root

  findPrevNode: (d) ->
    prevNodeID = null
    for leaf, i in @core.nodes
      if leaf._id == d._id
        break
      prevNodeID = leaf._id
    return null if prevNodeID is null or prevNodeID is "0"
    idPath = prevNodeID.split "_"
    root = @core.data[0]
    root = root.values[parseInt(idPath[i])] for i in [1..idPath.length-1]
    root

  removeNode: (d) ->
    parent = d.parent
    currentindex = parent.values.length
    for i in [0..parent.values.length - 1]
      if d._id == parent.values[i]._id
        currentindex = i
        break
    parent.values.splice currentindex, 1
    parent.children.splice currentindex, 1
    @core.table.setID parent, parent._id

  appendNode: (d, child) ->
    if d.values
      d.values.push(child)
    else if d._values
      d._values.push(child)
    else
      d.values = [child]
    @core.table.setID d, d._id
    #child.parent = d

  pastNode: (d, child) ->
    n = 0
    array = []
    for index in d.parent.values
      array[n] = index
      n = n + 1
      if d is index
        array[n] = child
        n = n + 1
    d.parent.values = array
    @core.table.setID d.parent, d.parent._id
    #@core.table.setID d.parent.values, d.parent.values._id

  findNodeByID: (id) ->
    idPath = id.split "_"
    root = @core.table.gridFilteredData[0]
    root = root.values[parseInt(idPath[i])] for i in [1..idPath.length-1]
    root

  deactivateAll: (d) ->
    d.activatedID = null
    if d.values
      d.values.forEach (item, index) => @core.utils.deactivateAll(item)
    if d._values
      d._values.forEach (item, index) => @core.utils.deactivateAll(item)
    return

  hasChildren: (d) ->
    values = d.values or d._values
    values and values.length

  isChild: (child, parent) ->
    u = @core.utils
    if u.hasChildren(parent)
      values = parent.values or parent._values
      for d in values
        return true if d is child
        return true if u.hasChildren(d) and u.isChild(child, d)
    false

  isParent: (parent, child) ->
    if @core.utils.hasChildren(parent)
      values = parent.values or parent._values
      _.contains(values, child)
    else
      false

  folded: (d) ->
    d._values and d._values.length

  # change icons during deployment-folding
  nestedIcons: (d)->
    if (d.depth-1) < 6
      indent = (d.depth-1)
    else
      indent = 5
    if d._values and d._values.length
      'expandable' + ' ' + 'indent' + indent
    else if d.values and d.values.length
      'collapsible' + ' ' + 'indent' + indent
    else
      'indent' + (indent)

  # similar in spirit to d3.functor()
  # https://github.com/mbostock/d3/wiki/Internals
  ourFunctor: (attr, element, etc) ->
    if typeof attr is 'function'
      attr(element,etc)
    else
      attr
