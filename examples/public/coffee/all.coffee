testTree = [
    catname: "collapsible"
    values: [
        catname: "indent1"
        AUG:
            label: "22"
            classes: "old"
        SEP:
            label: "22"
            classes: "old"
        OCT:
            label: "1,234"
            classes: "plan"
        NOV:
            label: "987"
            classes: "plan"
        DEC:
            label: "987"
            classes: "plan"
        JAN:
            label: "987"
            classes: "plan"
        FEB: "987"
        MAR: "67"
        APR: "4"
        MAY: "456"
        JUN: "347"
        JUL: "14"
    ,
        catname: "indent2"
        AUG:
            label: "22"
            classes: "old"
        SEP:
            label: "22"
            classes: "old"
        OCT:
            label: "1,234"
            classes: "plan"
        NOV:
            label: "987"
            classes: "plan"
        DEC:
            label: "987"
            classes: "plan"
        JAN:
            label: "987"
            classes: "plan"
        FEB: "987"
        MAR: "67"
        APR: "4"
        MAY: "456"
        JUN: "347"
        JUL: "14"
    ,
        catname: "collapsible"
        values: [
            catname: "indent2"
            AUG:
                label: "22"
            SEP:
                label: "22"
            OCT:
                label: "1,234"
                classes: "plan"
            NOV:
                label: "987"
                classes: "plan"
            DEC:
                label: "987"
                classes: "plan"
            JAN:
                label: "987"
                classes: "plan"
            FEB: "987"
            MAR: "67"
            APR: "4"
            MAY: "456"
            JUN: "347"
            JUL: "14"
        ]
    ]
,
    catname: "Section subtotal"
    AUG: "1"
    _classes: "subtotal"
,
    catname: ""
    _classes: "spacer"
,
    catname: "Expandable"
    _values: [
        catname: "indent1"
    ,
        catname: "indent2"
    ]
,
    catname: "independent row (link)"
    AUG:
        label: "22"
    SEP:
        label: "22"
    OCT:
        label: "1,234"
        classes: "plan"
    NOV:
        label: "987"
        classes: "plan"
    DEC:
        label: "987"
        classes: "plan"
    JAN:
        label: "987"
        classes: "plan"
    FEB: "987"
    MAR: "67"
    APR: "4"
    MAY: "456"
    JUN: "347"
    JUL: "14"
,
    catname: "indy row with %"
    AUG:
        label: "22"
    SEP:
        label: "22"
    OCT:
        label: "1,234"
        classes: "plan"
    NOV:
        label: "987"
        classes: "plan"
    DEC:
        label: "987"
        classes: "plan"
    JAN:
        label: "987"
        classes: "plan"
    FEB: "987"
    MAR: "67"
    APR: "4"
    MAY: "456"
    JUN: "347"
    JUL: "14"
,
    catname: "change"
    AUG:
        label: "22"
    SEP:
        label: "22"
    OCT:
        label: "1,234"
        classes: "plan"
    NOV:
        label: "987"
        classes: "plan"
    DEC:
        label: "987"
        classes: "plan"
    JAN:
        label: "987"
        classes: "plan"
    FEB: "987"
    MAR: "67"
    APR: "4"
    MAY: "456"
    JUN: "347"
    JUL: "14"
,
    catname: "indy row with %"
    AUG:
        label: "22"
    SEP:
        label: "22"
    OCT:
        label: "1,234"
        classes: "plan"
    NOV:
        label: "987"
        classes: "plan"
    DEC:
        label: "987"
        classes: "plan"
    JAN:
        label: "987"
        classes: "plan"
    FEB: "987"
    MAR: "67"
    APR: "4"
    MAY: "456"
    JUN: "347"
    JUL: "14"
,
    catname: "percent change"
    AUG:
        label: "22"
    SEP:
        label: "22"
    OCT:
        label: "1,234"
        classes: "plan"
    NOV:
        label: "987"
        classes: "plan"
    DEC:
        label: "987"
        classes: "plan"
    JAN:
        label: "987"
        classes: "plan"
    FEB: "987"
    MAR: "67"
    APR: "4"
    MAY: "456"
    JUN: "347"
    JUL: "14"
,
    catname: "inty & editable name"
    AUG:
        label: "22"
    SEP:
        label: "22"
    OCT:
        label: "1,234"
        classes: "plan"
    NOV:
        label: "987"
        classes: "plan"
    DEC:
        label: "987"
        classes: "plan"
    JAN:
        label: "987"
        classes: "plan"
    FEB: "987"
    MAR: "67"
    APR: "4"
    MAY: "456"
    JUN: "347"
    JUL: "14"
,
    catname: "Overall total"
    _classes: "total"
    AUG:
        label: "22"
    SEP:
        label: "22"
    OCT:
        label: "1,234"
        classes: "plan"
    NOV:
        label: "987"
        classes: "plan"
    DEC:
        label: "987"
        classes: "plan"
    JAN:
        label: "987"
        classes: "plan"
    FEB: "987"
    MAR: "67"
    APR: "4"
    MAY: "456"
    JUN: "347"
    JUL: "14"

]
testColumns = [
  key: "catname"
  label: "CATEGORY NAME"
  showCount: false
  width: "140px"
  isEditable: true
  classes: "keyfield"
,
  key: "AUG"
  label: "AUG"
  showCount: false
  width: "40px"
  isEditable: true
  classes: "keyfield"
,
  key: "SEP"
  label: "SEP"
  showCount: false
  width: "40px"
  isEditable: true
  classes: "keyfield"
,
  key: "OCT"
  label: "OCT"
  showCount: false
  width: "40px"
  isEditable: true
  classes: "keyfield"
,
  key: "NOV"
  label: "NOV"
  showCount: false
  width: "40px"
  isEditable: true
  classes: "keyfield"
,
  key: "DEC"
  label: "DEC"
  showCount: false
  width: "40px"
  isEditable: true
  classes: "keyfield"
,
  key: "JAN"
  label: "JAN"
  showCount: false
  width: "40px"
  isEditable: true
  classes: "keyfield"
,
  key: "FEB"
  label: "FEB"
  showCount: false
  width: "40px"
  isEditable: true
  classes: "keyfield"
,
  key: "MAR"
  label: "MAR"
  showCount: false
  width: "40px"
  isEditable: true
  classes: "keyfield"
,
  key: "APR"
  label: "APR"
  showCount: false
  width: "40px"
  isEditable: true
  classes: "keyfield"
,
  key: "MAY"
  label: "MAY"
  showCount: false
  width: "40px"
  isEditable: true
  classes: "keyfield"
,
  key: "JUN"
  label: "JUN"
  showCount: false
  width: "40px"
  isEditable: true
  classes: "plan"
,
  key: "JUL"
  label: "JUL"
  showCount: false
  width: "40px"
  isEditable: true
  classes: "keyfield"
]



grid = new window.TableStakes(
  columns: testColumns
  data: testTree
  el: "#example"
  sortable: true
  filterable: true
  resizable: true
  nested: true
  hierarchy_dragging: true
  reorder_dragging: true
).isDeletable(true)
grid.render()
