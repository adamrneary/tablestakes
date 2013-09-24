### Columns

Function and array of objects to define relation between [dataArray](data-manipulating.md) and corresponding table columns.
```coffeescript
grid = new window.TableStakes()
  .el("#example")
  .columns(columnsArray)
  .render()
```

Where *columnsArray* is array of objects ```{key: value}```. Possible variation of **key**:
* [*id*](#id) - pointer to **key** attribute of [dataArray](data-manipulating.md)
* [*label*](#label) - name of column
* *classes* - specific column class
* *format* - apply style formatting to output
* *isSortable* - allow to sort table rows in ascending (descending) order
* *isNested* - allow to build table with [nested data](data-manipulating.md#nested-data-expandablecollapsible-rows)
* *editable* - add special classes and event listeners to allow editing of table's cell
  * *onEdit* - editHandler apply changes to [dataArray](data-manipulating.md)
* *timeSeries* - some specific methods for columns and data gouped by time factor.

Additional option
* *custom editors* - additional option for *select*, *date*, *boolean* editors
* *total column* - the sum of several columns


#### id

*Required field*  
```{id: valueSelector}``` **valueSelector** should be on of keys from items of [dataArray](data-manipulating.md)

```coffeescript
columnsArray = [
  id: "id"    # column 1
,
  id: "type"  # column 2
]

dataArray = [
  id: "nerds for good"  # will be used, column 1
  type: "ahaha"         # will be used, column 2
  label: "LOL"          # will not be used
,
  type: "Historical"    # will be used, column 2
  id: "Simple Line"     # will be used, column 1
  port: undefined       # will not be used
]
```


#### label

Coming soon


#### classes

Coming soon


#### format

Coming soon


#### isSortable

Coming soon


#### isNested

Coming soon


#### editable

Coming soon


##### onEdit

Coming soon


#### timeSeries

Coming soon


#### Custom Editors

Coming soon


##### Select

Coming soon


##### Date

Coming soon


##### Boolean

Coming soon


#### Total Column

Coming soon

