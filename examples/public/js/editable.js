// Generated by CoffeeScript 1.4.0
var grid, testColumns, testTree;

testTree = [
  {
    key: "NVD3",
    type: "ahaha"
  }, {
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
  }, {
    key: "Legend",
    type: "Universal"
  }, {
    key: "New Root",
    type: "tatata"
  }, {
    key: {
      label: "yes",
      classes: "date"
    },
    type: "123"
  }
];

testColumns = [
  {
    key: "key",
    label: "Name",
    showCount: false,
    type: "text",
    isEditable: function(row) {
      return row.key === 'Horizontal Grouped Bar';
    },
    classes: "keyfield",
    click: function(d) {
      return d3.select(this).html("hallo you were clicked");
    }
  }, {
    key: "type",
    label: "Type",
    type: "text",
    classes: "name",
    isEditable: true
  }
];

grid = void 0;

grid = new window.TablesStakes({
  columns: testColumns,
  data: testTree,
  el: "#example"
});

grid.render();
