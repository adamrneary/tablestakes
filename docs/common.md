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
* [rowClasses()](#row-classes) - adding specific class custom row



##### Placement

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


##### Row Classes

Allows to apply custom classes to any (or all) rows. There are 2 ways to apply classes to table row.  
1. Function ```rowClasses(rowClassesResolver)``` takes 1 argument - pointer to function.  
2. Add pair ```{classes: "customeRowClass"}``` to every item of [dataArray](data-manipulating.md)

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