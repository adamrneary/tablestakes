// Generated by CoffeeScript 1.4.0
var Performance, tests;

tests = [
  {
    name: 'testInit',
    rows: 36,
    columns: 12
  }, {
    name: 'testUpdate',
    rows: 72,
    columns: 24
  }, {
    name: 'testRender'
  }
];

Performance = (function() {

  Performance.prototype.template = _.template('<div class="container">\n  <hr />\n  <div id="results">\n\n  </div>\n  <div id="example"></div>\n</div>');

  Performance.prototype.result_template = _.template('<div class="row">\n  <% for (var p in test) { %>\n      <% if (typeof test[p] === \'object\') { %>\n          <% for (var pp in test[p]) { %>\n            <b><%= pp %></b>: <%= test[p][pp] %>\n            <br />\n          <% } %>\n      <% } else { %>\n          <b><%= p %></b>: <%= test[p] %>\n          <br />\n      <% } %>\n  <% } %>\n  <pre> <%= code %> </pre>\n  <b>time: </b><%= time %>ms\n  <hr />\n</div>');

  function Performance(options) {
    this.el = options.el;
    this.tests = options.tests;
    this.render();
    this.runTest();
  }

  Performance.prototype.render = function() {
    return this.el.html(this.template());
  };

  Performance.prototype.runTest = function(counter) {
    var _this = this;
    if (counter == null) {
      counter = 0;
    }
    return setTimeout(function() {
      var start;
      start = Date.now();
      _this[_this.tests[counter].name](_this.tests[counter]);
      return setTimeout(function() {
        var end;
        end = Date.now();
        _this.showResult(end - start, counter);
        counter++;
        if (_this.tests[counter]) {
          return _this.runTest(counter);
        } else {

        }
      }, 0);
    }, 0);
  };

  Performance.prototype.showResult = function(time, counter) {
    return $(this.el).find('#results').append(this.result_template({
      time: time,
      test: this.tests[counter],
      code: this[this.tests[counter].name].toString()
    }));
  };

  Performance.prototype.generateData = function(rows, columns, configs) {
    var c, column, columnName, config, data, obj, p, _i, _j, _k, _len, _ref;
    data = {
      columns: [],
      data: []
    };
    for (c = _i = 1; 1 <= columns ? _i <= columns : _i >= columns; c = 1 <= columns ? ++_i : --_i) {
      columnName = 'p' + c;
      column = {
        id: columnName,
        label: columnName
      };
      if (configs) {
        for (config in configs) {
          column[config] = configs[config];
        }
      }
      data.columns.push(column);
    }
    for (p = _j = 1; 1 <= rows ? _j <= rows : _j >= rows; p = 1 <= rows ? ++_j : --_j) {
      obj = {};
      _ref = data.columns;
      for (_k = 0, _len = _ref.length; _k < _len; _k++) {
        column = _ref[_k];
        obj[column.id] = p;
      }
      data.data.push(obj);
    }
    return data;
  };

  Performance.prototype.testInit = function(options) {
    var data;
    data = this.generateData(options.rows, options.columns);
    return this.table = new window.TableStakes().el("#example").columns(data.columns).data(data.data).render();
  };

  Performance.prototype.testUpdate = function(options) {
    var data;
    data = this.generateData(options.rows, options.columns);
    return this.table.columns(data.columns).data(data.data).render();
  };

  Performance.prototype.testRender = function(options) {
    return this.table.render();
  };

  return Performance;

})();

$(document).ready(function() {
  var perf;
  return perf = new Performance({
    el: $('<div id="performance" />').appendTo('body'),
    tests: tests
  });
});