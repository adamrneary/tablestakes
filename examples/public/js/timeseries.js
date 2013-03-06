// Generated by CoffeeScript 1.4.0
var availableTimeframe, columns, data, displayPeriods, grid, labelFunction, toggle;

data = [
  {
    id: "nerds for good",
    mar: "mar1",
    apr: 'apr1'
  }, {
    id: "Simple Line",
    mar: "mar1",
    apr: 'apr1'
  }, {
    id: "Scatter / Bubble",
    mar: "mar1",
    apr: 'apr1'
  }, {
    id: "Stacked / Stream / Expanded Area",
    mar: "mar1",
    apr: 'apr1'
  }, {
    id: "Discrete Bar",
    mar: "mar1",
    apr: 'apr1'
  }, {
    id: "Grouped / Stacked Multi-Bar",
    mar: "mar1",
    apr: 'apr1'
  }, {
    id: "Horizontal Grouped Bar",
    mar: "mar1",
    apr: 'apr1'
  }, {
    id: "Line and Bar Combo",
    mar: "mar1",
    apr: 'apr1'
  }, {
    id: "Cumulative Line",
    mar: "mar1",
    apr: 'apr1'
  }, {
    id: "Line with View Finder",
    mar: "mar1",
    apr: 'apr1'
  }, {
    id: "Legend",
    mar: "mar1",
    apr: 'apr1'
  }, {
    id: "New Root",
    mar: "mar1",
    apr: 'apr1'
  }, {
    id: "1",
    mar: "mar1",
    apr: 'apr1'
  }
];

availableTimeframe = ['mar', 'apr'];

labelFunction = function(label) {
  return label.toUpperCase();
};

columns = [
  {
    id: "id",
    label: "Name",
    classes: "row-heading"
  }, {
    timeSeries: availableTimeframe,
    label: labelFunction,
    classes: 'well'
  }
];

grid = new window.TableStakes().el("#example").columns(columns).data(data).render();

displayPeriods = ['mar'];

toggle = true;

$('<button>display/hide</button>').appendTo('#temp').on('click', function(e) {
  toggle = !toggle;
  return grid.displayColumns(displayPeriods, toggle).render();
});
