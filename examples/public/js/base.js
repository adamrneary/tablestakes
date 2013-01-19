var drawGraph, testColumns, testTree;

testColumns = void 0;

testTree = void 0;

testTree = [
  {
    key: "NVD3",
    type: "ahaha",
    values: [
      {
        key: "Charts",
        values: [
          {
            key: "Simple Line",
            type: "Historical"
          }, {
            key: "Scatter / Bubble",
            type: "Snapshot"
          }, {
            key: "Stacked / Stream / Expanded Area",
            type: "Historical"
          }, {
            key: "Discrete Bar",
            type: "Snapshot"
          }, {
            key: "Grouped / Stacked Multi-Bar",
            type: "Snapshot / Historical"
          }, {
            key: "Horizontal Grouped Bar",
            type: "Snapshot"
          }, {
            key: "Line and Bar Combo",
            type: "Historical"
          }, {
            key: "Cumulative Line",
            type: "Historical"
          }, {
            key: "Line with View Finder",
            type: "Historical"
          }
        ]
      }, {
        key: "Chart Components",
        values: [
          {
            key: "Legend",
            type: "Universal"
          }
        ]
      }
    ]
  }, {
    key: "New Root",
    type: "tatata",
    values: [
      {
        key: "1",
        type: "123"
      }
    ]
  }
];

testColumns = [
  {
    key: "key",
    label: "Name",
    showCount: false,
    width: "400px",
    type: "text",
    classes: "key"
  }, {
    key: "type",
    label: "Type",
    width: "300px",
    type: "text",
    classes: "name"
  }
];

drawGraph = function() {
  var grid;
  grid = new Tablestakes.Table();
  grid.set('columns', testColumns);
  grid.set('data', testTree);
  //grid.columns(testColumns);
  //grid.data(testTree);
  return grid.render('#example_view');
};

$(document).ready(function() {
  return drawGraph();
});
