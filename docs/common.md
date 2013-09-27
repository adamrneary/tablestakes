# Tablestakes API Documentation

## General concepts

Since Tablestakes is built on [d3](https://github.com/mbostock/d3/), we tried to follow d3 conventions where possible. Two such concepts to improve usability and simplicity are:

1. A Tablestakes object is a closure with getter/setter methods
1. Methods that apply to rows are "functors"
1. Callbacks for interactivity

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

### Callbacks for interactivity

In order to maintain a strict separation of concerns between app data, app state, and app UI, all user interactions with a Tablestakes object are managed with callbacks.

The Tablestakes object is part of the app UI.

#### Separation of app UI (Tablestakes) and app state

A common requirement for table interactivity is a dynamic relationship to filters or timeframes, which would generally be considered app state rather than persistent app data.

As such, Tablestakes maintains no code that allows the user to adjust these values. They must be created outside of the table object (e.g. a filter textbox). Further, it's a best practice to avoid binding changes to these external UI elements directly to updates to the Tablestakes object. Instead:

1. User interactions with state-oriented UI objects should trigger updates to app state
1. Changes to app state should trigger updates to Tablestakes objects

#### Separation of app UI (Tablestakes) and app data

More importantly, since Tablestakes is interactive, it is important to remember that user changes to data are passed to callbacks and never interact with data directly. For example:

1. A user edits a value in an editable cell
1. Tablestakes will replace the cell's `editable` class with the `changed` class without re-rendering
1. Tablestakes calls the onEdit callback function to pass the new value to the app
1. The app's callback function manages all validation and persisting of the change
1. Changes to app data should trigger updates to Tablestakes objects

As such, the app should always bind Tablestakes objects to changes in app state and app data.

## The Tablestakes object

### Create a new instance of Tablestakes

```coffeescript
new window.TableStakes()
```

A Tablestakes object can be created without all required attributes being set. However, the required attributes must be set prior to calling `render()` to avoid catastrophe.

#### Providing attributes on instantiation

*TODO: Example of providing attributes on instantiation*

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
* Required: [data()](data.md)
* [isResizable()](#isResizable)
* [rowClasses()](#rowClasses)
* [filter()](#filter)
* [isDeletable()](#isDeletable)
* [isDraggable()](#isDraggable)
  * [auto scroll](#auto-scroll)

#### el()

Creates a new instance of a Tablestakes object inside of the specified DOM element.

*Required at instantiation*

* Getter: table.el() returns a String with the table element
* Setter: table.el(element) takes a String as an argument and sets the table element
* Default: There is no default value

```coffeescript
table = new Tablestakes().el("#example")
```

```html
<div id="example">
  <div>
    <table class="tablestakes">
    </table>
  </div>
</div>
```

#### isResizable()

Allows the user to change columns' widths by dragging.

* Getter: table.isResizable() returns a Boolean specifying if tables columns are resizable
* Setter: table.isResizable(flag) takes a Boolean specifying if tables columns are resizable
* Default: `true`

```coffeescript
new window.TableStakes()
  .el('#example')
  .columns(columns)
  .data(data)
  .isResizable(false)    # disable columns width changing
  .render()
```

#### rowClasses()

Apply custom classes to any (or all) rows.

* Getter: table.rowClasses() returns the rowClasses functor
* Setter: table.rowClasses(attr) applies the functor to all rows
* Default: No custom classes are applied by default

As a functor method, if the passed `attr` is a String, the classes will be applied to all rows. If the passed `attr` is a function, it will be applied to all rows.

Note: Rows also have a "classes" attribute covered in the [data()](data.md) section.

```coffeescript
data = [
  id: "apples"
  value: 123
,
  id: "bananas"
  value: 234
,
  id: "oranges"
  value: 345
,
  id: "kiwi"
  value: 456
  classes: "yum"
]

columns = [
  id: "id"
  label: "Name"
,
  id: "value"
  label: "Inventory count"
]

table = new window.TableStakes()
  .el("#example")
  .columns(columns)
  .data(data)
  .rowClasses (d) ->
    "highlight" if d.value > 250
  .render()
```

#### filter()

Filters rows by "keyword". Row filtering could be by one column or by some selected columns.

```filter(columns, keyword)``` function takes two arguments.

* **columns** - value of *id* field from [columnsArray](columns.md) or an array of column ids.
* **keyword** - argument to filter by

If the column values being filtered are strings (more common), the filter is applied with wildcards on either side. (This means both "apple" and "applesauce" would be a match if the filter was "apple.") If the column values being filtered are numeric (less common), it filters for an exact match.

*NOTE: If table is [nested](data-manipulating.md#nested-data-expandablecollapsible-rows), ["drag destination"](common.md#rowdestinationresolver) rows are excluded from filtering*

```coffeescript
table.filter "id", "apple"
```

#### isDeletable()

Provides mechanisms for removing rows.

Two methods are required to implement this functionality:

* [`isDeletable()`](#isDeletable) - A functor to resolve which rows could be deletable
* [`onDelete()`](#onDelete) - A callback function to update app data or state

##### isDeletable()

`table.isDeletable(true)` would mark all table rows as deletable. Or, provide a function to validate against each row:

```coffeescript
table.isDeletable (d) ->
  d.name isnt 'Customer' and d.position isnt 1
```

##### onDelete()

When the user attempts to delete a row, the callback function will be called with the row's id field.

```coffeescript
deleteHandler = (rowId) ->
  data = _.reject(data, (row) -> row.id is rowId)
  table.data(data).render()

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

table = new window.TableStakes()
  .el("#example")
  .columns(columns)
  .data(data)
  .isDeletable(deleteResolver)
  .onDelete(deleteHandler)
  .render()
```

_Note:_ Though this example is intentionally quite simple, it would be common for the callback function to manage any client-side validations and persistence of any data changes. The callback function should generally not trigger the `render()` function. Instead, the `render()` function should be bound to changes in the underlying data.

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
  table.data(data).render()
```

##### Hierarchy Dragging

```dragMode('hierarchy')``` for tables with [nested](data-manipulating.md#nested-data-expandablecollapsible-rows) values / rows.

```onDragHandler(rowSource, rowDestination)``` - specific for *hierarchy* draggable tables. Takes two arguments **rowSource** - extended item (row) which we currently drag; **rowDestination** - extended item (row) which we want to extend with new nested item (new nested row)

```isDragDestination(arg)``` - specific for *hierarchy* draggable tables. Function to resolve which rows could be rowDestination. **arg** should be *true/flase* statement, or pointer to [rowDestinationResolver](#rowdestinationresolver) function.

```coffeescript
onDragHandler = (rowSource, rowDestination) ->
  u = table.core.utils
  if target? and object? and
  not u.isChild(rowDestination, rowSource) and not u.isParent(rowDestination, rowSource)
    u.removeNode(rowSource)
    u.appendNode(rowDestination, rowSource)
    table.data(data).render()
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