# Tablestakes Common API

## General concepts

Since Tablestakes is built on [d3](https://github.com/mbostock/d3/), we tried to follow d3 conventions where possible. Two such concepts to improve usability and simplicity are:

1. A Tablestakes object is a closure with getter/setter methods
1. Methods that apply to rows are "functors"

### Getter/setter methods

Please see [http://bost.ocks.org/mike/chart](http://bost.ocks.org/mike/chart/).

One key advantage for using this approach in the wild is that table configurations pair well with [view hierarchies](http://www.adamrneary.com/2013/02/18/view_hierarchies_backbone/).

Suppose the table you eventually require involves the following:

```coffeescript
myTable = new window.TableStakes()
  .el(@el)
  .data(@data)
  .columns(@columns)
  .height(400)
  .render()
```

You might create a view class that implements the base table with any configuration that will apply to all tables in your app:

```coffeescript
module.exports = class BaseTableView extends View
  className: 'table-container'

  initialize: ->
    @table = new window.TableStakes()
      .el(@el)

    mediator.on 'searchString:change', (searchString, field) =>
      @table.filter field, searchString

    mediator.on 'route:rendered', () =>
      @table.render()
```

By binding the rendering of the table to a BackBone event, you release child view classes from having to render the table. Instead, they need only configure the table.

Perhaps you then have a particular type of table that only needs add configuration specific to its use:

```coffeescript
module.exports = class LargeTableView extends BaseTableView

  initialize: ->
    super

    @table.height(400)
```

Finally, you would have a view that actually implements the table and provides column configurations and data:

```coffeescript
@tableView = @createView LargeTableView
@tableView.table
  .data(@data)
  .columns(@columns)
```

As tables begin to require more and more configuration to achieve your goals, being able to separate functionality into view hierarchies results in more maintainable code.

### Functors

Since the term "functor" seems to mean something different to everyone or to different programming languages, I will presume that you disagree with my use of the term. Here's what I mean:

```coffeescript
ourFunctor: (attr, element, etc) ->
  if typeof attr is 'function'
    attr(element, etc)
  else
    attr
```

This is similar to [d3.functor](https://github.com/mbostock/d3/wiki/Internals#wiki-functor).

In our case, the functor generally applies to configurations that impact rows of data, such as `isEditable`. In the context of a column, you might see:

`isEditable: true`

…in which case the column is editable for all rows, or:

```coffeescript
isEditable: (d) ->
  d.editable
```

…in which case the column is editable only for those rows whose editable property is true. Naturally the logic for the function can be much more complex.

This approach provides much more granular controls over table configuration.

## The Tablestakes object

### Create a new instance of Tablestakes

```coffeescript
new window.TableStakes()
```

A Tablestakes object can be created without all required attributes being set. However, the required attributes must be set prior to calling `render()` to avoid catastrophe.

#### Providing attributes on instantation

TODO: Example of providing

#### Chaining setter methods and rendering

```coffeescript
myTable = new window.TableStakes()
  .el('#example')
  .data(myDataArray)
  .columns(myColumns)
  .render()
```

### Options

* Required at instantiation: [el()](#el)
* Required: [columns()](columns.md)
* Required: [data()](data-manipulating.md)
* [isResizable()](#resizable)
* [rowClasses()](#row-classes)
* [filter()](#filter)
* [isDeletable()](#deletable)
* [isDraggable()](#draggable)
  * [auto scroll](#auto-scroll)

#### el()

*Required at instantiation*

```coffeescript
table = new Tablestakes().el("#example")
```

Creates a new instance of a Tablestakes object inside of `#example`

```html
<div id="example">
  <div>
    <table class="tablestakes">
    </table>
  </div>
</div>
```

#### Resizable

Allows to change column's width. ```isResizable(arg)``` takes one argument **arg** *true* or *false* statement.
*by default this option is enabled*

```coffeescript
new window.TableStakes()
  .el('#example')
  .columns(columns)
  .data(data)
  .isResizable(false)    # disable columns width changing
  .render()
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

grid = new window.TableStakes()
  .el("#example")
  .columns(columns)
  .data(data)
  .rowClasses (d) ->
    "total2" if d.etc is 'etc2'
  .render()
```


#### Filter

Filter rows by "keyword". Row filtering could be by one column or by some selected columns.

```filter(columns, keyword)``` function takes two arguments. **columns** - value of *id* field from [columnsArray](columns.md); or array of values. **keyword** - argument to filter by.
*NOTE: If table is [nested](data-manipulating.md#nested-data-expandablecollapsible-rows), ["drag destination"](common.md#rowdestinationresolver) rows excludes from filtering*

```coffeescript
grid.filter "type", "c2"
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
  * [Reorder Draggable Example](../public/examples/reorder_dragging.coffee)
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


##### Auto Scroll

Allow to scroll table with reorder dragging. When [dataArray](data-manipulating.md) has a lot of items (rows) the tables height could be more than desired. To manually fix table's height and save table's column name method ```height(value)``` should be called. Where **value** is height of ```<tbody>``` element.
When method ```height(value)``` is called, then class *scrollable* will be assigned to ```<table>``` and [resizable](#resizable) option disabled.

```coffeescript
new window.TableStakes()
  .el('#example')
  .height(500)
  .columns(columns)
  .data(data)
  .render()
```

[Example](/public/examples/nested_filterable.coffee)