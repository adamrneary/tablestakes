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
    if @core.utils.hasChildren(parent)
      values = parent.values or parent._values
      for d in values
        return true if d is child
        return true if @core.utils.hasChildren(d) and @core.utils.isChild(child, d)
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
    if d.depth isnt 1
      if (d.depth-1) < 6
        indent = (d.depth-1)
      else
        indent = 6
      if d._values and d._values.length
        'expandable' + ' ' + 'indent' + indent
      else
        if d.values and d.values.length
          'collapsible' + ' ' + 'indent' + indent
        else
          'indent' + (indent+1)
    else unless d.children?
      'indent1'
    else
      if d._values and d._values.length
        'expandable'
      else
        if d.values and d.values.length
          'collapsible'
        else
          'indent1'

  # similar in spirit to d3.functor()
  # https://github.com/mbostock/d3/wiki/Internals
  ourFunctor: (attr, element) ->
    if typeof attr is 'function'
      attr(element)
    else
      attr
