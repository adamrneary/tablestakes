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

Coming Soon

