(function() {
  describe('column', function() {
  return it('constructor', function() {
    var column;
    column = new window.TableStakesLib.Column({
      a: 'b'
    });
    assert(column);
    return assert(column.a === 'b');
  });
});

}).call(this);

(function() {
  describe("Events", function() {
  var column, columns, d, data, event, table;
  event = null;
  table = null;
  data = [
    {
      id: "NVD3",
      type: "ahaha",
      values: [
        {
          id: "Charts",
          _values: [
            {
              id: "Simple Line",
              type: "Historical"
            }, {
              id: "Scatter / Bubble",
              type: "Snapshot"
            }, {
              id: "Stacked / Stream / Expanded Area",
              type: "Historical"
            }, {
              id: "Discrete Bar",
              type: "Snapshot"
            }, {
              id: "Grouped / Stacked Multi-Bar",
              type: "Snapshot / Historical"
            }, {
              id: "Horizontal Grouped Bar",
              type: "Snapshot"
            }, {
              id: "Line and Bar Combo",
              type: "Historical"
            }, {
              id: "Cumulative Line",
              type: "Historical"
            }, {
              id: "Line with View Finder",
              type: "Historical"
            }
          ]
        }, {
          id: "Chart Components",
          values: [
            {
              id: "Legend",
              type: "Universal"
            }
          ]
        }
      ]
    }, {
      id: "New Root",
      type: "tatata",
      classes: "rowcustom1",
      values: [
        {
          id: "1",
          type: "123",
          classes: "rowcustom"
        }
      ]
    }
  ];
  columns = [
    {
      id: "id",
      label: "Name",
      classes: 'row-heading',
      isEditable: true,
      isNested: true
    }, {
      id: "type",
      label: "Type",
      isEditable: true
    }
  ];
  d = {
    _hiddenvalues: [],
    _id: "0_6",
    activatedID: "Simple Line",
    changedID: null,
    depth: 1,
    id: "Simple Line",
    parent: {},
    type: "Snapshot",
    x: 0.5,
    y: 1
  };
  column = {
    id: "id",
    label: "Name",
    classes: "row-heading",
    onEdit: function() {
      return d.id = 'test';
    }
  };
  before(function() {
    return d3.select('body').append('div').attr('id', 'example');
  });
  it('window.TableStakesLib.Events is function', function() {
    assert(window.TableStakesLib);
    assert(typeof window.TableStakesLib.Events === 'function');
    return assert(window.TableStakesLib.Events);
  });
  it('events constructor', function() {
    event = new window.TableStakesLib.Events({
      core: {
        table: {
          isInRender: false,
          el: function() {
            return '#example';
          },
          onDrag: function() {
            return d;
          },
          dragMode: function() {
            return 'reorder';
          }
        },
        update: function() {
          return true;
        },
        utils: {
          getCurrentColumnIndex: function() {
            return 3;
          },
          findNextNode: function() {
            return d;
          },
          findPrevNode: function() {
            return d;
          },
          deactivateAll: function() {
            return true;
          }
        },
        columns: [
          {
            'id': 2
          }, {
            'id': 3
          }, {
            'id': 4
          }
        ],
        nodes: [],
        data: [
          {
            'id': 2
          }
        ]
      }
    });
    return assert(event);
  });
  it('blur', function() {
    var td;
    table = new window.TableStakes().el("#example").data(data).columns(column);
    td = d3.select('#NVD3');
    return assert(event.blur(td, d, column));
  });
  it('keydown press tab, shiftKey-false and ColumnIndex=3', function() {
    var td, _table;
    d3.event = {
      'keyCode': 9,
      'shiftKey': false,
      preventDefault: function() {
        return true;
      },
      stopPropagation: function() {
        return true;
      }
    };
    _table = new window.TableStakes().el("#example").columns(columns).data(data).render();
    event = _table.core.events;
    td = d3.select('td').node();
    return assert(event.keydown(td, d, column));
  });
  it('keydown press tab, shiftKey-false and ColumnIndex = 1', function() {
    var td, _table;
    d3.event = {
      'keyCode': 9,
      'shiftKey': false,
      preventDefault: function() {
        return true;
      },
      stopPropagation: function() {
        return true;
      }
    };
    td = d3.select('td').node();
    _table = new window.TableStakes().el("#example").columns(columns).data(data).render();
    event = _table.core.events;
    td = d3.select('td').node();
    return assert(event.keydown(td, d, column));
  });
  it('keydown press tab, shiftKey-true and ColumnIndex = 3', function() {
    var td, _table;
    d3.event = {
      'keyCode': 9,
      'shiftKey': true,
      preventDefault: function() {
        return true;
      },
      stopPropagation: function() {
        return true;
      }
    };
    _table = new window.TableStakes().el("#example").columns(columns).data(data).render();
    event = _table.core.events;
    td = d3.select('td').node();
    return assert(event.keydown(td, d, column));
  });
  it('keydown press tab, shiftKey-true and  ColumnIndex = 0', function() {
    var td, _table;
    d3.event = {
      'keyCode': 9,
      'shiftKey': true,
      preventDefault: function() {
        return true;
      },
      stopPropagation: function() {
        return true;
      }
    };
    td = d3.select('td').node();
    _table = new window.TableStakes().el("#example").columns(columns).data(data).render();
    event = _table.core.events;
    td = d3.select('td').node();
    return assert(event.keydown(td, d, column));
  });
  it('keydown press up', function() {
    var td, _table;
    d3.event = {
      'keyCode': 38,
      'shiftKey': true,
      preventDefault: function() {
        return true;
      },
      stopPropagation: function() {
        return true;
      }
    };
    _table = new window.TableStakes().el("#example").columns(columns).data(data).render();
    event = _table.core.events;
    td = d3.select('td').node();
    return assert(event.keydown(td, d, column));
  });
  it('keydown press down', function() {
    var td, _table;
    d3.event = {
      'keyCode': 40,
      'shiftKey': true,
      preventDefault: function() {
        return true;
      },
      stopPropagation: function() {
        return true;
      }
    };
    _table = new window.TableStakes().el("#example").columns(columns).data(data).render();
    event = _table.core.events;
    td = d3.select('td').node();
    return assert(event.keydown(td, d, column));
  });
  it('keydown press Enter', function() {
    var td;
    d3.event = {
      'keyCode': 13,
      'shiftKey': true,
      preventDefault: function() {
        return true;
      },
      stopPropagation: function() {
        return true;
      }
    };
    td = d3.select('#NVD3');
    return assert(event.keydown(td, d, column));
  });
  it('keydown press Escape', function() {
    var td;
    d3.event = {
      'keyCode': 27,
      'shiftKey': true,
      'x': 45,
      'y': 56,
      preventDefault: function() {
        return true;
      },
      stopPropagation: function() {
        return true;
      }
    };
    td = d3.select('#NVD3');
    return assert(event.keydown(td, d, column));
  });
  it('dragStart', function() {
    var tr;
    tr = d3.select('#NVD3');
    return tr['getBoundingClientRect'] = function() {
      return [34, 23];
    };
  });
  it('dragMove', function() {
    var tr;
    return tr = d3.select('#NVD3');
  });
  it('resizeDrag');
  it('editableClick', function() {
    var td;
    return td = d3.select('#NVD3');
  });
  it('nestedClick', function() {});
  it('toggleBoolean', function() {
    var td;
    td = d3.select('td').node();
    assert(event.toggleBoolean(td, d, 2, 0, column));
    return assert(d.id === 'test');
  });
  return it('selectClick', function() {
    var td;
    d.id = 0;
    d3.event = {
      target: {
        value: 1
      }
    };
    td = d3.select('td').node();
    assert(event.selectClick(td, d, 2, 0, column));
    return assert(d.id === 'test');
  });
});

}).call(this);

(function() {
  describe("Render", function() {
  var categories, columns, data, editHandler, render, table, table2;
  render = null;
  table = null;
  table2 = null;
  data = [
    {
      id: "task 1",
      category: "engineering",
      date: '2013-01-01',
      complete: true,
      classes: "total"
    }, {
      id: "task 2",
      category: "qa",
      date: '2013-02-01',
      complete: true
    }
  ];
  categories = ['engineering', 'design', 'qa'];
  editHandler = function(id, field, newValue) {
    var row, _i, _len;
    for (_i = 0, _len = data.length; _i < _len; _i++) {
      row = data[_i];
      if (row.id === id) {
        row[field] = newValue;
      }
    }
    return table.data(data).render();
  };
  columns = [
    {
      id: "id",
      label: "Task",
      classes: "row-heading",
      isEditable: true,
      onEdit: editHandler
    }, {
      id: "category",
      label: "Task category",
      isEditable: true,
      editor: 'select',
      selectOptions: categories,
      onEdit: editHandler
    }, {
      id: "date",
      label: "Date due",
      isEditable: true,
      editor: 'calendar',
      onEdit: editHandler,
      showCount: true
    }, {
      id: "complete",
      label: "Is complete",
      isEditable: true,
      editor: 'boolean',
      onEdit: editHandler
    }
  ];
  it('is a function', function() {
    assert(window.TableStakes);
    return assert(typeof window.TableStakes === 'function');
  });
  it('window.TableStakesLib.Core', function() {
    var deleteCheck, deleteHandler;
    deleteCheck = function(d) {
      return d.type === 'Historical' || d.type === 'Snapshot';
    };
    deleteHandler = function(id) {
      data = _.reject(data, function(row) {
        return row.id === id;
      });
      return table.data(data).render();
    };
    return table = new window.TableStakes().el("#example").columns(columns).data(data).isDeletable(deleteCheck).onDelete(deleteHandler).dragMode('reorder').isDraggable(true).render().rowClasses(function(d) {
      if (d.etc === 'etc6') {
        return "total2";
      }
    });
  });
  it('render constructor', function() {
    render = new window.TableStakesLib.Core;
    render['table'] = {
      isDraggable: function() {
        return false;
      }
    };
    return assert(render);
  });
  return it('update', function() {
    var rendertest;
    rendertest = new window.TableStakesLib.Core;
    rendertest['table'] = {
      isInRender: false,
      isDraggable: function() {
        return false;
      },
      update: function() {
        return true;
      }
    };
    rendertest['selection'] = {
      call: function() {
        return true;
      }
    };
    return assert(rendertest.update());
  });
});

}).call(this);

(function() {
  describe("Tablestakes API ", function() {
  var columns, data, editHandler, setNewTreeValue, table;
  table = null;
  data = [
    {
      id: "NVD3",
      type: "ahaha",
      values: [
        {
          id: "Charts",
          values: [
            {
              id: "Simple Line",
              type: "Historical",
              values: [
                {
                  id: "Scatter / Bubble",
                  type: "Snapshot",
                  values: [
                    {
                      id: "Stacked / Stream / Expanded Area",
                      type: "Historical",
                      values: [
                        {
                          id: "Stacked / Stream / Expanded Area",
                          type: "Historical",
                          values: [
                            {
                              id: "Line and Bar Combo",
                              type: "Historical",
                              values: [
                                {
                                  id: "Cumulative Line",
                                  type: "Historical"
                                }
                              ]
                            }, {
                              id: "Cumulative Line",
                              type: "Historical"
                            }
                          ]
                        }
                      ]
                    }
                  ]
                }
              ]
            }
          ]
        }, {
          id: "Chart Components",
          _values: [
            {
              id: "Legend",
              type: "Universal"
            }
          ]
        }
      ]
    }
  ];
  setNewTreeValue = function(tree, id, field, newValue) {
    var node, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = tree.length; _i < _len; _i++) {
      node = tree[_i];
      if (node.id === id) {
        _results.push(node[field] = newValue);
      } else if (node.values != null) {
        _results.push(setNewTreeValue(node.values, id, field, newValue));
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };
  editHandler = function(id, field, newValue) {
    setNewTreeValue(data, id, field, newValue);
    return table.data(data).render();
  };
  columns = [
    {
      id: "id",
      label: "Name",
      isEditable: true,
      isNested: true,
      onEdit: editHandler
    }, {
      id: "type",
      label: "Type",
      isEditable: true,
      onEdit: editHandler
    }
  ];
  it('is a function', function() {
    assert(window.TableStakes);
    return assert(typeof window.TableStakes === 'function');
  });
  it('has a basic constructor', function() {
    table = new window.TableStakes;
    table.render();
    return assert(table);
  });
  describe("chainable getter/setter methods for most internal attributes", function() {
    return it('should return the value set by the same method', function() {
      var attributes;
      attributes = ['data', 'isDeletable', 'onDelete', 'isResizable', 'isSortable', 'dragMode', 'isDraggable', 'onDrag', 'isDragDestination', 'el', 'rowClasses'];
      return _.each(attributes, function(attribute) {
        var testVal;
        testVal = Math.random();
        assert(table[attribute](testVal) === table);
        return assert(table[attribute]() === testVal);
      });
    });
  });
  describe("margin", function() {
    it('can set all margin attributes at once', function() {
      var testHash;
      testHash = {
        top: 40,
        right: 10,
        bottom: 30,
        left: 50
      };
      assert(table.margin(testHash) === table);
      assert(table.margin()['top'] === 40);
      assert(table.margin()['right'] === 10);
      assert(table.margin()['bottom'] === 30);
      return assert(table.margin()['left'] === 50);
    });
    return it('can set 1-2 margin attributes at a time', function() {
      var testHash;
      testHash = {
        top: 40,
        right: 10,
        bottom: 30,
        left: 50
      };
      assert(table.margin(testHash) === table);
      assert(table.margin({
        top: 100
      }) === table);
      assert(table.margin({
        left: 200,
        right: 300
      }) === table);
      assert(table.margin()['top'] === 100);
      assert(table.margin()['right'] === 300);
      assert(table.margin()['bottom'] === 30);
      return assert(table.margin()['left'] === 200);
    });
  });
  return describe("columns", function() {
    it('returns table on set and an array of Columns on get');
    it('table options', function() {
      typeof table.filterCondition === 'object';
      table.filterCondition === 'd3_Map';
      typeof table.core === 'object';
      table.core === 'core';
      typeof table.events === 'object';
      table.events === 'events';
      typeof table.utils === 'object';
      return table.utils === 'utils';
    });
    it('column', function() {
      table = new window.TableStakes().el("#example").data(data);
      return assert(table.columns(columns));
    });
    it('setID', function() {
      var _this = this;
      table.gridData = [
        {
          values: table.data()
        }
      ];
      table.columns().forEach(function(column, i) {
        return table.gridData[0][column['id']] = column['id'];
      });
      table.setID(table.gridData[0], "0");
      return assert(table.gridData[0]._id === "0");
    });
    it('render', function() {
      assert(typeof table.render === 'function');
      return assert(table.render());
    });
    it('update', function() {
      var _this = this;
      d3.select(table.el()).html('').call(function(selection) {
        return assert(table.update(selection));
      });
      return assert(typeof table.update === 'function');
    });
    it('dispatchManualEvent', function() {
      return assert(typeof table.dispatchManualEvent === 'function');
    });
    it('table.set(testdata) and table.get(testdata)', function() {
      assert(table.set('isResizable', true));
      return assert(table.get('isResizable') === true);
    });
    it('table.is(testdata)', function() {
      return assert(table.is('isResizable') === true);
    });
    it('columns', function() {
      table = new window.TableStakes().el("#example").data(data);
      columns = 'isnt array';
      return assert(table.columns(columns));
    });
    it('table.is(testdata)', function() {
      assert(table.is('isResizable') === true);
      return assert(table.is('isEditable') === false);
    });
    it('filter', function() {
      assert(typeof table.filter === 'function');
      assert(table.filter('key', 'S'));
      assert(table.filter('id', 'NVD3'));
      return assert(table.filterCondition.get('id') === 'NVD3');
    });
    return it('has a basic constructor', function() {
      table = new window.TableStakes({
        'editable': true
      });
      return assert(table);
    });
  });
});

}).call(this);

(function() {
  describe("Utils", function() {
  var a, b, c, d, f, table, utils;
  table = null;
  utils = null;
  d = {
    values: ['a'],
    _values: [],
    activatedID: true
  };
  a = {
    values: [],
    activatedID: true
  };
  b = {
    _values: [a],
    activatedID: true
  };
  c = {
    activatedID: true,
    parent: {
      values: [],
      activatedID: true
    }
  };
  c.parent.values = [b, c];
  c.parent.children = [b, c];
  f = {
    values: [a, c],
    activatedID: true
  };
  it('window.TableStakesLib.Utils is function', function() {
    return assert(typeof window.TableStakesLib.Utils === 'function');
  });
  it('utils constructor', function() {
    utils = new window.TableStakesLib.Utils({
      core: {
        utils: {
          deactivateAll: function(d) {
            return d.activatedID = null;
          },
          hasChildren: function() {
            return true;
          },
          isChild: function() {
            return true;
          }
        },
        data: [
          {
            values: [
              {
                _id: "0_0",
                values: [
                  {
                    _id: "0_0_0"
                  }
                ]
              }
            ],
            _id: "0"
          }
        ],
        columns: [
          {
            id: 'id'
          }, {
            id: 'type'
          }
        ],
        nodes: [
          {
            _id: "0"
          }, {
            _id: "0_0"
          }, {
            _id: "0_0_0"
          }
        ],
        table: {
          gridFilteredData: [
            {
              values: [
                {
                  _id: "0_0",
                  values: [
                    {
                      _id: "0_0_0"
                    }
                  ]
                }
              ],
              _id: "0"
            }
          ],
          setID: function() {
            return true;
          }
        }
      }
    });
    return assert(utils);
  });
  it('hasChildren', function() {
    assert(utils.hasChildren(d));
    return assert(utils.hasChildren(a) === 0);
  });
  it('folded', function() {
    return assert(utils.folded(d) === 0);
  });
  it('appendNode', function() {
    assert(d.values.length === 1);
    utils.appendNode(d, a);
    assert(d.values.length === 2);
    assert(b._values.length === 1);
    utils.appendNode(b, a);
    assert(b._values.length === 2);
    utils.appendNode(c, a);
    return assert(c.values.length === 1);
  });
  it('pastNode', function() {
    utils.pastNode(c, a);
    return assert(c.parent.values[2] === a);
  });
  it('removeNode', function() {
    utils.removeNode(c);
    return assert(c.parent.values.length === 2);
  });
  it('findNextNode', function() {
    assert(utils.findNextNode({
      _id: "0_0"
    })._id === "0_0_0");
    return assert(utils.findNextNode({
      _id: "0_0_0"
    }) === null);
  });
  it('findPrevNode', function() {
    assert(utils.findPrevNode({
      _id: "0_0_0"
    })._id === "0_0");
    return assert(utils.findPrevNode({
      _id: "0_0"
    }) === null);
  });
  it('findNodeByID', function() {
    return utils.findNodeByID("0_0") === {
      _id: "0_0",
      values: [
        {
          _id: "0_0_0"
        }
      ]
    };
  });
  it('getCurrentColumnIndex', function() {
    return assert(utils.getCurrentColumnIndex('id') === 0);
  });
  it('deactivateAll', function() {
    utils.deactivateAll(f);
    assert(f.activatedID === null);
    assert(c.activatedID === null);
    assert(a.activatedID === null);
    utils.deactivateAll(b);
    return assert(b.activatedID === null);
  });
  it('isChild', function() {
    var utilsTest2;
    assert(utils.isChild(d, b));
    assert(utils.isChild(a, f));
    utilsTest2 = new window.TableStakesLib.Utils({
      core: {
        utils: {
          deactivateAll: function(d) {
            return d.activatedID = null;
          },
          hasChildren: function() {
            return false;
          },
          isChild: function() {
            return false;
          }
        }
      }
    });
    return assert(utilsTest2.isChild(f, a) === false);
  });
  return it('isParent', function() {
    var utilsTest;
    utils.isParent(a, d);
    utilsTest = new window.TableStakesLib.Utils({
      core: {
        utils: {
          deactivateAll: function(d) {
            return d.activatedID = null;
          },
          hasChildren: function() {
            return false;
          }
        }
      }
    });
    return utilsTest.isParent(a, d);
  });
});

}).call(this);

