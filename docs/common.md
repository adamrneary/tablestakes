# Tablestakes Common API

![GitHub Logo](/docs/common/common_1.png)

### Creating instance of tablestakes

```coffeescript
new window.TableStakes()
```

### Options

* [el()](#placement) - element to render table
* [columns()](columns.md) - list of columns
* [data()](#data-manipulating) - data manipulating
* [rowClasses()](#row-classes) - adding specific class custom row
* [timeSeries](#timeseries) - specific data manipulating methods



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
  
  
  
##### Data manipulating

Set data to table. 
```data``` - array, that describes table's data. Each element of ```data``` describes row.  
Every array's item (row) should be JavaScript object.  
Every array's item (row) could contain any quantity of pairs {key: value}, but used will be only those which have reference from colums array.  
*For example*: ```columns``` array defines to use values from row by keys **id** and **label**

```coffeescript
data = [
  id: "nerds for good"  # will be used
  label: "LOL"          # will not be used
  type: "ahaha"         # will be used
,
  id: "Simple Line"
  type: "Historical"
  reference: null       # will not be used
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
  .render()
```

###### timeSeries

Tablestakes lib contains some specific methods for columns and data gouped by tyme factor.



##### Row Classes

*Coming Soon*