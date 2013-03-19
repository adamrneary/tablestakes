var TablesStakesCore;

window.TablesStakes = (function() {

  TablesStakes.prototype.attributes = {};

  TablesStakes.prototype.margin = {
    top: 0,
    right: 0,
    bottom: 0,
    left: 0
  };

  TablesStakes.prototype.width = 960;

  TablesStakes.prototype.height = 500;

  TablesStakes.prototype.id = Math.floor(Math.random() * 10000);

  TablesStakes.prototype.header = true;

  TablesStakes.prototype.noData = "No Data Available.";

  TablesStakes.prototype.childIndent = 20;

  TablesStakes.prototype.columns = [
    {
      key: "key",
      label: "Name",
      type: "text"
    }
  ];

  TablesStakes.prototype.tableClassName = "class";

  TablesStakes.prototype.iconOpenImg = "img/expand.gif";

  TablesStakes.prototype.iconCloseImg = "img/collapse.gif";

  TablesStakes.prototype.dispatch = d3.dispatch("elementClick", "elementDblclick", "elementMouseover", "elementMouseout");

  TablesStakes.prototype.columnResize = true;

  TablesStakes.prototype.gridData = [];

  TablesStakes.prototype.gridFilteredData = [];

  TablesStakes.prototype.tableObject = null;

  TablesStakes.prototype.minWidth = 50;

  TablesStakes.prototype.tableWidth = 0;

  TablesStakes.prototype.containerID = null;

  TablesStakes.prototype.isInRender = false;

  TablesStakes.prototype.filterCondition = [];

  function TablesStakes(options) {
    var key;
    this.set('sortable', false);
    this.set('editable', false);
    this.set('deletable', false);
    this.set('filterable', false);
    this.set('dragable', false);
    if (options != null) {
      for (key in options) {
        this.set(key, options[key]);
      }
    }
  }

  TablesStakes.prototype.render = function(selector) {
    var _this = this;
    console.log('Table render');
    this.gridData = [
      {
        values: this.get('data')
      }
    ];
    this.columns.forEach(function(column, i) {
      return _this.gridData[0][column['key']] = column['key'];
    });
    this.setID(this.gridData[0], "0");
    this.gridFilteredData = this.gridData;
    this.setFilter(this.gridFilteredData[0], this.filterCondition);
    if (selector != null) {
      this.containerID = selector;
    }
    d3.select(this.containerID).datum(this.gridFilteredData).call(function(selection) {
      return _this.update(selection);
    });
    console.log('table render end');
    return this;
  };

  TablesStakes.prototype.update = function(selection) {
    var _this = this;
    console.log('table update, selection:', selection);
    selection.each(function(data) {
      return new TablesStakesCore({
        selection: selection,
        table: _this,
        data: data
      });
    });
    this.isInRender = false;
    return this;
  };

  TablesStakes.prototype.calculateTableWidth = function() {
    var tableWidth;
    tableWidth = 0;
    this.get('columns').forEach(function(column, index) {
      return tableWidth += parseInt(column.width);
    });
    return this.tableWidth = tableWidth;
  };

  TablesStakes.prototype.dispatchManualEvent = function(target) {
    var mousedownEvent;
    if (target.dispatchEvent && document.createEvent) {
      mousedownEvent = document.createEvent("MouseEvent");
      mousedownEvent.initMouseEvent("dblclick", true, true, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null);
      target.dispatchEvent(mousedownEvent);
    } else {
      if (document.createEventObject) {
        mousedownEvent = document.createEventObject(window.event);
        mousedownEvent.button = 1;
        target.fireEvent("dblclick", mousedownEvent);
      }
    }
  };

  TablesStakes.prototype.setID = function(node, prefix) {
    var _this = this;
    node['_id'] = prefix;
    if (node.values) {
      node.values.forEach(function(subnode, i) {
        return _this.setID(subnode, prefix + "_" + i);
      });
    }
    if (node._values) {
      return node._values.forEach(function(subnode, i) {
        return _this.setID(subnode, prefix + "_" + i);
      });
    }
  };

  TablesStakes.prototype.setFilter = function(data, filter) {
    var i, key, matchFound, self, _i, _j, _k, _len, _ref, _ref1, _ref2;
    self = this;
    if (typeof data._hiddenvalues === "undefined") {
      data['_hiddenvalues'] = [];
    }
    if (data.values) {
      data.values = data.values.concat(data._hiddenvalues);
      data._hiddenvalues = [];
      for (i = _i = _ref = data.values.length - 1; _i >= 0; i = _i += -1) {
        if (this.setFilter(data.values[i], filter) === null) {
          data._hiddenvalues.push(data.values.splice(i, 1)[0]);
        }
      }
    }
    if (data._values) {
      data._values = data._values.concat(data._hiddenvalues);
      data._hiddenvalues = [];
      for (i = _j = _ref1 = data._values.length - 1; _j >= 0; i = _j += -1) {
        if (this.setFilter(data._values[i], filter) === null) {
          data._hiddenvalues.push(data._values.splice(i, 1)[0]);
        }
      }
    }
    if (data.values && data.values.length > 0) {
      return data;
    }
    if (data._values && data._values.length > 0) {
      return data;
    }
    matchFound = true;
    _ref2 = filter.keys();
    for (_k = 0, _len = _ref2.length; _k < _len; _k++) {
      key = _ref2[_k];
      if (data[key]) {
        if (data[key].indexOf(filter.get(key)) === -1) {
          matchFound = false;
        }
      } else {
        matchFound = false;
      }
    }
    if (matchFound) {
      return data;
    }
    return null;
  };

  TablesStakes.prototype.set = function(key, value, options) {
    if ((key != null) && (value != null)) {
      this.attributes[key] = value;
    }
    switch (key) {
      case 'columns':
        this.filterCondition = d3.map([]);
    }
    return this;
  };

  TablesStakes.prototype.get = function(key) {
    return this.attributes[key];
  };

  TablesStakes.prototype.setMargin = function(margin) {
    if (margin == null) {
      return this.margin;
    }
    this.margin.top = (typeof margin.top !== "undefined" ? margin.top : this.margin.top);
    this.margin.right = (typeof margin.right !== "undefined" ? margin.right : this.margin.right);
    this.margin.bottom = (typeof margin.bottom !== "undefined" ? margin.bottom : this.margin.bottom);
    return this.margin.left = (typeof margin.left !== "undefined" ? margin.left : this.margin.left);
  };

  TablesStakes.prototype.Sortable = function(_) {
    if ((_ != null)) {
      this.isSortable = _;
      return this;
    } else {
      return this.isSortable;
    }
  };

  return TablesStakes;

})();

TablesStakesCore = (function() {

  function TablesStakesCore(options) {
    console.log('core constructor, options:', options);
    this.table = options.table;
    this.selection = options.selection;
    this.data = options.data;
    this.columns = this.table.get('columns');
    this.render();
  }

  TablesStakesCore.prototype.getCurrentColumnIndex = function(id) {
    var col, currentindex, i, _i, _len, _ref;
    console.log('core getCurrentColumnIndex, id:', id);
    currentindex = this.columns.length;
    _ref = this.columns;
    for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
      col = _ref[i];
      if (col.key === id) {
        currentindex = i;
        break;
      }
    }
    return currentindex;
  };

  TablesStakesCore.prototype.findNextNode = function(d) {
    var i, idPath, leaf, nextNodeID, root, _i, _j, _len, _ref, _ref1;
    console.log('core findNextNode');
    nextNodeID = null;
    _ref = this.nodes;
    for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
      leaf = _ref[i];
      if (leaf._id === d._id) {
        if (this.nodes.length !== i + 1) {
          nextNodeID = this.nodes[i + 1]._id;
        }
        break;
      }
    }
    if (nextNodeID === null) {
      return null;
    }
    idPath = nextNodeID.split("_");
    root = this.data[0];
    for (i = _j = 1, _ref1 = idPath.length - 1; 1 <= _ref1 ? _j <= _ref1 : _j >= _ref1; i = 1 <= _ref1 ? ++_j : --_j) {
      root = root.values[parseInt(idPath[i])];
    }
    return root;
  };

  TablesStakesCore.prototype.findPrevNode = function(d) {
    var i, idPath, leaf, prevNodeID, root, _i, _j, _len, _ref, _ref1;
    console.log('core findPrevNode');
    prevNodeID = null;
    _ref = this.nodes;
    for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
      leaf = _ref[i];
      if (leaf._id === d._id) {
        break;
      }
      prevNodeID = leaf._id;
    }
    if (prevNodeID === null || prevNodeID === "0") {
      return null;
    }
    idPath = prevNodeID.split("_");
    root = this.data[0];
    for (i = _j = 1, _ref1 = idPath.length - 1; 1 <= _ref1 ? _j <= _ref1 : _j >= _ref1; i = 1 <= _ref1 ? ++_j : --_j) {
      root = root.values[parseInt(idPath[i])];
    }
    return root;
  };

  TablesStakesCore.prototype.keydown = function(node, d) {
    switch (d3.event.keyCode) {
      case 9:
        return this.key_tab(node, d);
      case 38:
        return this.key_up(node, d);
      case 40:
        return this.key_down(node, d);
    }
  };

  TablesStakesCore.prototype.key_tab = function(node, d) {
    var currentindex, nextNode, prevNode;
    d3.event.preventDefault();
    d3.event.stopPropagation();
    currentindex = this.getCurrentColumnIndex(d.activatedID);
    if (d3.event.shiftKey === false) {
      if (currentindex < this.columns.length - 1) {
        d.activatedID = this.columns[currentindex + 1].key;
      } else {
        nextNode = this.findNextNode(d, this.nodes);
        if (nextNode !== null) {
          nextNode.activatedID = this.columns[0].key;
          d.activatedID = null;
        }
      }
    } else {
      if (currentindex > 0) {
        d.activatedID = this.columns[currentindex - 1].key;
      } else {
        prevNode = this.findPrevNode(d, this.nodes);
        if (prevNode !== null) {
          prevNode.activatedID = this.columns[this.columns.length - 1].key;
          d.activatedID = null;
        }
      }
    }
    return this.update();
  };

  TablesStakesCore.prototype.key_down = function(node, d) {
    var currentindex, nextNode;
    nextNode = this.findNextNode(d);
    currentindex = this.getCurrentColumnIndex(d.activatedID);
    if (nextNode !== null) {
      nextNode.activatedID = this.columns[currentindex].key;
      d.activatedID = null;
    }
    return this.update();
  };

  TablesStakesCore.prototype.key_up = function(node, d) {
    var currentindex, prevNode;
    prevNode = this.findPrevNode(d, this.nodes);
    currentindex = this.getCurrentColumnIndex(d.activatedID);
    if (prevNode !== null) {
      prevNode.activatedID = this.columns[currentindex].key;
      d.activatedID = null;
    }
    return this.update();
  };

  TablesStakesCore.prototype.keyup = function(node, d) {
    switch (d3.event.keyCode) {
      case 13:
        d.activatedID = null;
        this.update();
        break;
      case 27:
        d3.select(node).node().value = d[d.activatedID];
        d.activatedID = null;
        this.update();
    }
  };

  TablesStakesCore.prototype.blur = function(node, d, column) {
    var cell, columnKey, hz;
    cell = d3.select(node);
    columnKey = d3.select(node)[0][0].parentNode.getAttribute("ref");
    hz = d3.select(node)[0][0];
    cell.text(d3.select(node).node().value);
    d[columnKey] = d3.select(node).node().value;
    d[column.key] = d3.select('td input').node().value;
    if (this.table.isInRender === false) {
      d.activatedID = null;
      return this.update();
    }
  };

  TablesStakesCore.prototype.click = function(node, d, _, unshift) {
    var self;
    console.log('core click');
    d.activatedID = null;
    d3.event.stopPropagation();
    if (d3.event.shiftKey && !unshift) {
      self = this;
      d.values && d.values.forEach(function(node) {
        if (node.values || node._values) {
          return self.click(this, node, 0, true);
        }
      });
      return true;
    }
    if (d.values) {
      d._values = d.values;
      d.values = null;
    } else {
      d.values = d._values;
      d._values = null;
    }
    return this.update();
  };

  TablesStakesCore.prototype.dragstart = function(node, d) {
    var self, targetRow;
    console.log('dragstart');
    self = this;
    if (this.table.get('dragable') === true) {
      targetRow = this.table.containerID + " tbody tr";
      this.draggingObj = d._id;
      this.draggingTargetObj = null;
      return d3.selectAll(targetRow).on("mouseover", function(d) {
        if (self.draggingObj === d._id.substring(0, self.draggingObj.length)) {
          return;
        }
        d3.select(this).style("background-color", "red");
        return self.draggingTargetObj = d._id;
      }).on("mouseout", function(d) {
        d3.select(this).style("background-color", null);
        return self.draggingTargetObj = null;
      });
    }
  };

  TablesStakesCore.prototype.dragmove = function(d) {
    if (this.table.get('dragable') === true) {
      return console.log('dragmove');
    }
  };

  TablesStakesCore.prototype.dragend = function(node, d) {
    var child, parent, targetRow;
    if (this.table.get('dragable') === true) {
      console.log('dragend');
      targetRow = this.table.containerID + " tbody tr";
      d3.selectAll(targetRow).on("mouseover", null).on("mouseout", null).style("background-color", null);
      if (this.draggingTargetObj === null) {
        return;
      }
      parent = this.findNodeByID(this.draggingTargetObj);
      child = this.findNodeByID(this.draggingObj);
      this.removeNode(child);
      this.appendNode(parent, child);
      return this.update();
    }
  };

  TablesStakesCore.prototype.removeNode = function(d) {
    var currentindex, i, parent, _i, _ref;
    parent = d.parent;
    currentindex = parent.values.length;
    for (i = _i = 0, _ref = parent.values.length - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
      if (d._id === parent.values[i]._id) {
        currentindex = i;
        break;
      }
    }
    parent.values.splice(currentindex, 1);
    parent.children.splice(currentindex, 1);
    return this.table.setID(parent, parent._id);
  };

  TablesStakesCore.prototype.appendNode = function(d, child) {
    if (d.values) {
      d.values.push(child);
    } else if (d._values) {
      d._values.push(child);
    } else {
      d.values = [child];
    }
    return this.table.setID(d, d._id);
  };

  TablesStakesCore.prototype.findNodeByID = function(id) {
    var i, idPath, root, _i, _ref;
    idPath = id.split("_");
    root = this.table.gridFilteredData[0];
    for (i = _i = 1, _ref = idPath.length - 1; 1 <= _ref ? _i <= _ref : _i >= _ref; i = 1 <= _ref ? ++_i : --_i) {
      root = root.values[parseInt(idPath[i])];
    }
    return root;
  };

  TablesStakesCore.prototype.deactivateAll = function(d) {
    var _this = this;
    d.activatedID = null;
    if (d.values) {
      d.values.forEach(function(item, index) {
        return _this.deactivateAll(item);
      });
    }
    if (d._values) {
      d._values.forEach(function(item, index) {
        return _this.deactivateAll(item);
      });
    }
  };

  TablesStakesCore.prototype.editable = function(node, d, _, unshift) {
    console.log('core editable');
    this.deactivateAll(this.data[0]);
    d.activatedID = d3.select(d3.select(node).node().parentNode).attr("meta-key");
    return this.update();
  };

  TablesStakesCore.prototype.icon = function(d) {
    if (d._values && d._values.length) {
      return this.table.iconOpenImg;
    } else {
      if (d.values && d.values.length) {
        return this.table.iconCloseImg;
      } else {
        return "";
      }
    }
  };

  TablesStakesCore.prototype.folded = function(d) {
    return d._values && d._values.length;
  };

  TablesStakesCore.prototype.hasChildren = function(d) {
    var values;
    values = d.values || d._values;
    return values && values.length;
  };

  TablesStakesCore.prototype.update = function() {
    var _this = this;
    this.table.isInRender = true;
    return this.selection.transition().call(function(selection) {
      return _this.table.update(selection);
    });
  };

  TablesStakesCore.prototype.render = function() {
    var depth, drag, dragbehavior, i, node, self, tableEnter, tbody, thead, theadRow1, theadRow2, wrap, wrapEnter,
      _this = this;
    self = this;
    console.log('core render start');
    if (!this.data[0]) {
      this.data[0] = {
        key: this.table.noData
      };
    }
    this.tree = d3.layout.tree().children(function(d) {
      return d.values;
    });
    this.nodes = this.tree.nodes(this.data[0]);
    wrap = d3.select(this.table.containerID).selectAll("div").data([[this.nodes]]);
    wrapEnter = wrap.enter().append("div").attr("class", "nvd3 nv-wrap nv-indentedtree");
    tableEnter = wrapEnter.append("table");
    this.table.calculateTableWidth();
    this.tableObject = wrap.select("table").attr("class", this.table.tableClassName).attr("style", "table-layout:fixed;").attr("width", this.table.tableWidth + "px");
    drag = d3.behavior.drag().on("drag", function(d, i) {
      var column_newX, column_x, index, table_newX, table_x, th;
      th = d3.select(this).node().parentNode;
      column_x = parseFloat(d3.select(th).attr("width"));
      column_newX = d3.event.x;
      if (self.table.minWidth < column_newX) {
        d3.select(th).attr("width", column_newX + "px");
        index = parseInt(d3.select(th).attr("ref"));
        self.columns[index].width = column_newX + "px";
        table_x = parseFloat(self.tableObject.attr("width"));
        table_newX = table_x + (column_newX - column_x);
        return self.tableObject.attr("width", table_newX + "px");
      }
    });
    if (this.table.header) {
      thead = tableEnter.append("thead");
      theadRow1 = thead.append("tr");
      this.columns.forEach(function(column, i) {
        var th;
        th = theadRow1.append("th").attr("width", (column.width ? column.width : "100px")).attr("ref", i).style("text-align", (column.type === "numeric" ? "right" : "left"));
        th.append("span").text(column.label);
        if (_this.table.get('sortable') === true) {
          if (_this.table.get('deletable') === true) {
            th.style("position", "relative");
            return th.append("div").attr("class", "table-resizable-handle").text('&nbsp;').call(drag);
          } else {
            if (i !== _this.columns.length - 1) {
              th.style("position", "relative");
              return th.append("div").attr("class", "table-resizable-handle").text('&nbsp;').call(drag);
            }
          }
        }
      });
      if (this.table.get('deletable') === true) {
        theadRow1.append("th").text("delete");
      }
      if (this.table.get('filterable') === true) {
        theadRow2 = thead.append("tr");
        this.columns.forEach(function(column, i) {
          var keyFiled;
          keyFiled = column.key;
          self = _this;
          return theadRow2.append("th").attr("meta-key", column.key).append("input").attr("type", "text").on("keyup", function(d) {
            self.table.filterCondition.set(column.key, d3.select(this).node().value);
            self.table.gridFilteredData = self.table.gridData;
            self.table.setFilter(self.table.gridFilteredData[0], self.table.filterCondition);
            self.table.setID(self.table.gridFilteredData[0], self.table.gridFilteredData[0]._id);
            return self.update();
          });
        });
      }
    }
    console.log('core render body');
    tbody = this.tableObject.selectAll("tbody").data(function(d) {
      return d;
    });
    tbody.enter().append("tbody");
    depth = d3.max(this.nodes, function(node) {
      return node.depth;
    });
    console.log(this.table.height, depth, this.table.childIndent);
    this.tree.size([this.table.height, depth * this.table.childIndent]);
    console.log('core render nodes');
    i = 0;
    node = tbody.selectAll("tr").data(function(d) {
      return d;
    }, function(d) {
      return d.id || (d.id === ++i);
    });
    node.exit().remove();
    node.select("img.nv-treeicon").attr("src", function(d) {
      return _this.icon(d);
    }).classed("folded", this.folded);
    self = this;
    dragbehavior = d3.behavior.drag().origin(Object).on("dragstart", function(a, b, c) {
      console.log('dragstart2');
      return self.dragstart(this, a, b, c);
    }).on("drag", function(a, b, c) {
      console.log('dragstart2');
      return self.dragmove(this, a, b, c);
    }).on("dragend", function(a, b, c) {
      console.log('dragstart2');
      return self.dragend(this, a, b, c);
    });
    this.nodeEnter = node.enter().append("tr").call(dragbehavior);
    if (this.nodeEnter[0][0]) {
      d3.select(this.nodeEnter[0][0]).style("display", "none");
    }
    console.log('core render end');
    this.columns.forEach(function(column, index) {
      return _this.renderColumn(column, index, node);
    });
    if (this.table.get('deletable') === true) {
      this.nodeEnter.append("td").attr("class", function(d) {
        var row_classes;
        row_classes = "";
        if (typeof d.classes !== "undefined") {
          row_classes = d.classes;
        }
        return row_classes;
      }).append("a").attr("href", "#").text("delete").on("click", function(d) {
        if (confirm("Are you sure you are going to delete this?")) {
          _this.removeNode(d);
          return _this.update();
        }
      });
    }
    return node.order().on("click", function(d) {
      return self.table.dispatch.elementClick({
        row: this,
        data: d,
        pos: [d.x, d.y]
      });
    }).on("dblclick", function(d) {
      return self.table.dispatch.elementDblclick({
        row: this,
        data: d,
        pos: [d.x, d.y]
      });
    }).on("mouseover", function(d) {
      return self.table.dispatch.elementMouseover({
        row: this,
        data: d,
        pos: [d.x, d.y]
      });
    }).on("mouseout", function(d) {
      return self.table.dispatch.elementMouseout({
        row: this,
        data: d,
        pos: [d.x, d.y]
      });
    });
  };

  TablesStakesCore.prototype.renderColumn = function(column, index, node) {
    var col_classes, nodeName, self,
      _this = this;
    console.log('renderColumn start', index, column);
    self = this;
    col_classes = "";
    if (typeof column.classes !== "undefined") {
      col_classes += column.classes;
    }
    nodeName = this.nodeEnter.append("td").attr("meta-key", column.key).attr("class", function(d) {
      var row_classes;
      row_classes = "";
      if (typeof d.classes !== "undefined") {
        row_classes = d.classes;
      }
      return col_classes + " " + row_classes;
    });
    if (index === 0) {
      nodeName.style("padding-left", function(d) {
        return (index ? 0 : (d.depth - 1) * _this.table.childIndent + (_this.icon(d) ? 0 : 16)) + "px";
      }, "important").style("text-align", (column.type === "numeric" ? "right" : "left")).attr("ref", column.key);
      nodeName.append("img").classed("nv-treeicon", true).classed("nv-folded", this.folded).attr("src", function(d) {
        return _this.icon(d);
      }).style("width", "14px").style("height", "14px").style("padding", "0 1px").style("display", function(d) {
        if (_this.icon(d)) {
          return "inline-block";
        } else {
          return "none";
        }
      }).on("click", function(a, b, c) {
        return self.click(this, a, b, c);
      });
    }
    console.log('core renderColumn renderNode');
    nodeName.each(function(td) {
      return self.renderNode(this, column, td, nodeName);
    });
    if (column.showCount) {
      return nodeName.append("span").attr("class", "nv-childrenCount").text(function(d) {
        if ((d.values && d.values.length) || (d._values && d._values.length)) {
          return "(" + ((d.values && d.values.length) || (d._values && d._values.length)) + ")";
        } else {
          return "";
        }
      });
    }
  };

  TablesStakesCore.prototype.renderNode = function(node, column, td, nodeName) {
    var editable, self;
    console.log('renderNode start');
    self = this;
    editable = this.table.get('editable');
    if (td.activatedID === column.key) {
      d3.select(node).append("span").attr("class", d3.functor(column.classes)).append("input").attr('type', 'text').attr('value', function(d) {
        return d[column.key] || "";
      }).on("keydown", function(d) {
        return self.keydown(this, d);
      }).on("keyup", function(a, b, c) {
        return self.keyup(this, a, b, c);
      }).on("blur", function(d) {
        return self.blur(this, d, column);
      }).node().focus();
      console.log('columns=', this.columns);
    } else {
      d3.select(node).append("span").attr("class", d3.functor(column.classes)).text(function(d) {
        if (column.format) {
          return column.format(d);
        } else {
          return d[column.key] || "-";
        }
      });
    }
    return nodeName.select("span").on("click", function(a, b, c) {
      if (editable && column.isEditable) {
        return self.editable(this, a, b, c);
      }
    });
  };

  return TablesStakesCore;

})();
