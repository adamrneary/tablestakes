# Tablestakes Common API

![GitHub Logo](/docs/common/common_1.png)

### Creating instance of tablestakes

```coffeescript
new window.TableStakes()
```

### Options

* [el()](#placement) - element to render table
* [columns()](columns.md) - list of columns
* [data()](data-manipulating.md) - data manipulating
* [rowClasses()](#row-classes) - adding specific class to custom row
* [isDeletable()](#deletable) - delete table rows
* [isDraggable()](#draggable) - reorder table rows with "drag and drop"



#### Placement

```coffeescript
new window.TableStakes()
  .el("#example")
  .render()
```
Will create new instance of table placed inside of ```#example```
```html
<div id="example">
  <div>
    <table class="tablestakes">
    </table>
  </div>
</div>
```


#### Row Classes

Allows to apply custom classes to any (or all) rows. There are 2 ways to apply classes to table row.  
1. Function ```rowClasses(rowClassesResolver)``` takes 1 argument - pointer to function.  
2. Add pair ```{classes: "customeRowClass"}``` to every item of [dataArray](data-manipulating.md)

```rowClassesResolver``` takes 1 argument - item of dataArray (row). Function returns string value of row's class.

```coffeescript
data = [
  id: "Grouped / Stacked Multi-Bar"
  type: "Snapshot / Historical"
  etc: 'etc1'
,
  id: "Horizontal Grouped Bar"
  type: "Snapshot"
  etc: 'etc2'
,
  id: "Line and Bar Combo"
  type: "Historical"
  etc: 'etc3'
,
  id: "1"
  type: "123"
  etc: 'etc4'
  classes: "total"
]

columns = [
  id: "id"
  label: "Name"
,
  id: "type"
  label: "Type"
,
  id: "etc"
  label: "Etc"
]

new window.TableStakes()
  .el("#example")
  .columns(columns)
  .data(data)
  .rowClasses (d) ->
    "total2" if d.etc is 'etc2'
  .render()
```


#### Deletable

To add functionality of removing table rows two methods should be called:  
[```isDeletable(arg)```](#deleteresolver) - function to resolve which rows could be deletable. **arg** should be *true/flase* statement, or pointer to [deleteResolver](#deleteresolver) function.
[```onDelete(deleteHandler)```](#deletehandler) - function to update [dataArray](data-manipulate.md) after delete button clicked.

##### deleteResolver()

Function calls for every item from [dataArray](data-manipulate.md) to resolve which table's row will be deletable.  
```deleteResolver(rowItem)``` takes one argument **rowItem** item from dataArray] and return *true/false*.

```coffeescript
deleteResolver = (rowItem) ->
  rowItem.id % 2
```

##### deleteHandler()

function calls every time when table's row deletes.  
```deleteHandler(rowId)``` takes one argument **rowId**. Its the same as value from pair ```{id: value}``` of dataArray's item.
```coffeescript
deleteHandler = (rowId) ->
  data = _.reject(data, (row) -> row.id is rowId)
  grid.data(data).render()
```

```coffeescript
data = [
  id: 1
  type: "ahaha"
,
  id: 2
  type: "Historical"
,
  id: 3
  type: "Snapshot"
,
  id: 4
  type: "Historical"
]

columns = [
  id: "id"
  label: "Name"
,
  id: "type"
  label: "Type"
]

grid = new window.TableStakes()
  .el("#example")
  .columns(columns)
  .data(data)
  .isDeletable(deleteResolver)
  .onDelete(deleteHandler)
  .render()
```


#### Draggable

Allows to drag one selected table row from one place to another. There are two options:
* [reorder](#reorder-dragging)
  * [Reorder Draggable Example](/public/examples/reorder_dragging.coffee)
* [hierarchy](#hierarchy-dragging)
  * [Hierarchy Draggable Example](/public/examples/hierarchy_dragging.coffee)

For both options ```isDraggable(arg)``` should be called to enable dragging. It takes one argument **arg**. **arg** should be *true/flase* statement, or pointer to [dragResolver](#dragresolver) function.  
And ```onDrag(onDragHandler)``` - function to update [dataArray](data-manipulating.md) when you end dragging. It takes one argument - pointer to [afterDrag](#ondraghandler) function.

##### dragResolver()

Function calls for every item from [dataArray](data-manipulate.md) to resolve which table's row will be deletable.  
```dragResolver(rowItem)``` takes one argument **rowItem** item from dataArray and return *true/false*.

```coffeescript
dragResolver = (rowItem) ->
  rowItem.id % 2
```

##### onDragHandler()

Function calls every time when dragging is over. Arguments of function depends on dragging options (["reorder"](#reorder-dragging) or ["hierarchy"](#hierarchy-dragging))

##### Reorder Dragging

```dragMode('reorder')``` for tables without [nested](data-manipulating.md#nested-data-expandablecollapsible-rows) values / rows.

```onDragHandler(row, index)``` - specific for *reorder* draggable tables. Takes two arguments **row** - extended item from [dataArray](data-manipulating.md); **index** - number of items (rows) from begining of [dataArray](data-manipulating.md).
```coffeescript
onDragHandler = (object, index) ->
  data = _.without(data, object)
  data.splice(index, 0, object)
  grid.data(data).render()
```

##### Hierarchy Dragging

```dragMode('hierarchy')``` for tables with [nested](data-manipulating.md#nested-data-expandablecollapsible-rows) values / rows.

```onDragHandler(rowSource, rowDestination)``` - specific for *hierarchy* draggable tables. Takes two arguments **rowSource** - extended item (row) which we currently drag; **rowDestination** - extended item (row) which we want to extend with new nested item (new nested row)

```isDragDestination(arg)``` - specific for *hierarchy* draggable tables. Function to resolve which rows could be rowDestination. **arg** should be *true/flase* statement, or pointer to [rowDestinationResolver](#rowdestinationresolver) function.

```coffeescript
onDragHandler = (rowSource, rowDestination) ->
  u = grid.core.utils
  if target? and object? and
  not u.isChild(rowDestination, rowSource) and not u.isParent(rowDestination, rowSource)
    u.removeNode(rowSource)
    u.appendNode(rowDestination, rowSource)
    grid.data(data).render()
```

###### rowDestinationResolver()

Function calls for every item from [dataArray](data-manipulate.md) to resolve which table's row will could be destination for draggable rows.  
```rowDestinationResolver(rowItem)``` takes one argument **rowItem** extended item from dataArray and return *true/false*.
```coffeescript
rowDestinationResolver = (rowItem) ->
  rowItem.depth > 1
```

