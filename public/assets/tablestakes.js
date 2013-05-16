(function() {
  if (!window.TableStakesLib) {
  window.TableStakesLib = {};
}

window.TableStakesLib.Column = (function() {
  function Column(options) {
    var key;

    if (options != null) {
      for (key in options) {
        this[key] = options[key];
      }
    }
  }

  return Column;

})();

}).call(this);

(function() {
  if (!window.TableStakesLib) {
  window.TableStakesLib = {};
}

window.TableStakesLib.Events = (function() {
  function Events(options) {
    this.core = options.core;
  }

  Events.prototype.keydown = function(node, d, column) {
    switch (d3.event.keyCode) {
      case 9:
        return this._handleTab(node, d, column);
      case 38:
        return this._handleUpDown(node, d, column, false);
      case 40:
        return this._handleUpDown(node, d, column, true);
      case 13:
        return this._handleEnter(node, d, column);
      case 27:
        return this._handleEscape(node, d, column);
    }
  };

  Events.prototype._handleTab = function(node, d, column) {
    var currentindex, index, nextNode, prevNode, start;

    currentindex = this.core.utils.getCurrentColumnIndex(d.activatedID);
    if (d3.event.shiftKey === false) {
      index = this.core.utils.findEditableColumn(d, currentindex + 1, true);
      if (index != null) {
        this.core._makeInactive(node);
        this.blur(node, d, column);
        d.activatedID = this.core.columns[index].id;
      } else {
        nextNode = this.core.utils.findNextNode(d, this.core.nodes);
        if (nextNode != null) {
          index = this.core.utils.findEditableColumn(nextNode, 0, true);
          if (index != null) {
            this.core._makeInactive(node);
            this.blur(node, d, column);
            d.activatedID = null;
            nextNode.activatedID = this.core.columns[index].id;
          }
        }
      }
    } else {
      index = this.core.utils.findEditableColumn(d, currentindex - 1, false);
      if (index != null) {
        this.core._makeInactive(node);
        this.blur(node, d, column);
        d.activatedID = this.core.columns[index].id;
      } else {
        prevNode = this.core.utils.findPrevNode(d, this.core.nodes);
        if (prevNode != null) {
          start = this.core.columns.length - 1;
          index = this.core.utils.findEditableColumn(prevNode, start, false);
          this.core._makeInactive(node);
          this.blur(node, d, column);
          prevNode.activatedID = this.core.columns[index].id;
          d.activatedID = null;
        }
      }
    }
    d3.event.preventDefault();
    d3.event.stopPropagation();
    return this.core.update();
  };

  Events.prototype._handleUpDown = function(node, d, column, isUp) {
    var currentindex, nextNode;

    currentindex = this.core.utils.getCurrentColumnIndex(d.activatedID);
    nextNode = this.core.utils.findEditableCell(d, column, isUp);
    if (nextNode != null) {
      this.blur(node, d, column);
      nextNode.activatedID = this.core.columns[currentindex].id;
      this.core._makeInactive(node);
      d.activatedID = null;
    }
    return this.core.update();
  };

  Events.prototype._handleEnter = function(node, d, column) {
    return this.blur(node, d, column);
  };

  Events.prototype._handleEscape = function(node, d, column) {
    d3.select(node).node().value = d[d.activatedID];
    d.activatedID = null;
    return this.core.update();
  };

  Events.prototype.blur = function(node, d, column) {
    var val;

    if (!this.core.table.isInRender) {
      val = d3.select(node).text();
      if (val !== d[column.id]) {
        d.changed = column.id;
      }
      if (val !== d[d.activatedID]) {
        this._applyChangedState(d);
        if (column.onEdit) {
          column.onEdit(d.id, column.id, val);
        }
      }
      d.activatedID = null;
      return this.core.update();
    }
  };

  Events.prototype._applyChangedState = function(d) {
    var _ref;

    if ((_ref = d.changedID) == null) {
      d.changedID = [];
    }
    if (d.changedID.indexOf(d.activatedID) === -1) {
      return d.changedID.push(d.activatedID);
    }
  };

  Events.prototype.dragStart = function(tr, d) {
    this.initPosition = $(tr).position();
    this._makeRowDraggable(tr);
    return $(tr).css({
      left: this.initPosition.left,
      top: this.initPosition.top
    });
  };

  Events.prototype._makeRowDraggable = function(tr) {
    var cellWidths, onMouseOut, onMouseOver, rowWidth, self, tableEl;

    self = this;
    rowWidth = $(tr).width();
    cellWidths = _.map($(tr).find('td'), function(td) {
      return $(td).width();
    });
    d3.select(tr).classed('dragged', true);
    $(tr).width(rowWidth);
    _.each($(tr).find('td'), function(td, i) {
      return $(td).width(cellWidths[i]);
    });
    onMouseOver = function(d, i) {
      var c, isDestination;

      c = self.core;
      self.destinationIndex = i;
      isDestination = c.utils.ourFunctor(c.table.isDragDestination(), d);
      self.destination = (isDestination ? d : null);
      if (isDestination) {
        return d3.select(this).classed(self._draggableDestinationClass(), true);
      }
    };
    onMouseOut = function(d) {
      return d3.select(this).classed(self._draggableDestinationClass(), false);
    };
    tableEl = this.core.table.el();
    d3.selectAll(tableEl + ' tbody tr:not(.dragged)').on('mouseover', onMouseOver).on('mouseout', onMouseOut);
    if (this.core.table.dragMode() === 'reorder') {
      return d3.selectAll(tableEl + ' thead tr').on('mouseover', onMouseOver).on('mouseout', onMouseOut);
    }
  };

  Events.prototype._draggableDestinationClass = function() {
    var dragMode;

    dragMode = this.core.table.dragMode();
    if (dragMode != null) {
      return dragMode + '-draggable-destination';
    } else {
      return '';
    }
  };

  Events.prototype.dragMove = function(tr, d, x, y) {
    return $(tr).css({
      left: this.initPosition.left + d3.event.x,
      top: this.initPosition.top + d3.event.y
    });
  };

  Events.prototype.dragEnd = function(tr, d) {
    var onDrag, tableEl;

    d3.select(tr).classed('dragged', false);
    tableEl = this.core.table.el();
    d3.selectAll(tableEl + ' tbody tr, ' + tableEl + ' thead tr').classed(this._draggableDestinationClass(), false).on('mouseover', null).on('mouseout', null);
    if (this.core.table.onDrag) {
      onDrag = this.core.table.onDrag();
      switch (this.core.table.dragMode()) {
        case 'reorder':
          return onDrag(d, this.destinationIndex);
        case 'hierarchy':
          return onDrag(d, this.destination);
      }
    }
  };

  Events.prototype.resizeDrag = function(node) {
    var new_width_left, new_width_right, notTooSmall, old_width_left, old_width_right, th;

    th = node.parentNode;
    old_width_left = parseFloat(d3.select(th).style("width"));
    old_width_right = parseFloat(d3.select(th.nextSibling).style("width"));
    new_width_left = d3.event.x;
    new_width_right = old_width_left + old_width_right - new_width_left;
    notTooSmall = new_width_left > this.core.table._minColumnWidth && new_width_right > this.core.table._minColumnWidth;
    if (notTooSmall) {
      d3.select(th).attr("width", new_width_left + "px");
      d3.select(th).style("width", new_width_left + "px");
      d3.select(th.nextSibling).attr("width", new_width_right + "px");
      return d3.select(th.nextSibling).style("width", new_width_right + "px");
    }
  };

  Events.prototype.editableClick = function(node, d, _, unshift) {
    var target, _node;

    target = d3.event.target;
    _node = d3.select(node);
    if (!(_node.classed('active') || $(target).is('a'))) {
      this.core.utils.deactivateAll(this.core.data[0]);
      d.activatedID = d3.select(d3.select(node).node()).attr("meta-key");
      this.core.update();
      d3.event.preventDefault();
    }
    return d3.event.stopPropagation();
  };

  Events.prototype.nestedClick = function(node, d, _, unshift) {
    var self, target;

    target = d3.event.target;
    if (!($(target).is('a') || d3.select(target).classed('active'))) {
      if (d3.event.shiftKey && !unshift) {
        self = this;
        if (d.values) {
          d.values.forEach(function(_node) {
            if (_node.values || _node._values) {
              return self.nestedClick(this, _node, 0, true);
            }
          });
        }
      } else {
        if (d.values) {
          d._values = d.values;
          d.values = null;
        } else {
          d.values = d._values;
          d._values = null;
        }
      }
      this.core.update();
      d3.event.preventDefault();
    }
    return d3.event.stopPropagation();
  };

  Events.prototype.toggleBoolean = function(node, d, _, unshift, column) {
    if (column.onEdit) {
      column.onEdit(d.id, column.id, !d[column.id]);
    }
    return this.core.update();
  };

  Events.prototype.selectClick = function(node, d, _, unshift, column) {
    var val;

    val = d3.event.target.value;
    if (val !== d[column.id]) {
      if (column.onEdit) {
        column.onEdit(d.id, column.id, val);
      }
    }
    return this.core.update();
  };

  Events.prototype.buttonClick = function(node, d, _, unshift, column) {
    var val;

    val = d3.event.target.value;
    if (column.onClick) {
      column.onClick(d.id, column.id, val);
    }
    return this.core.update();
  };

  Events.prototype.toggleSort = function(el, column) {
    column.desc = !column.desc;
    d3.selectAll('.sorted-desc').classed('sorted-desc', false);
    d3.selectAll('.sorted-asc').classed('sorted-asc', false);
    d3.selectAll('th').filter(function(d) {
      if (d.id !== column.id) {
        return d.desc = null;
      }
    });
    return this.core.table.sort(column.id, column.desc);
  };

  return Events;

})();

}).call(this);

(function() {
  if (!window.TableStakesLib) {
  window.TableStakesLib = {};
}

window.TableStakesLib.HeadRow = (function() {
  function HeadRow(options) {
    if (options != null) {
      _.extend(this, options);
    }
  }

  return HeadRow;

})();

}).call(this);

(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

if (!window.TableStakesLib) {
  window.TableStakesLib = {};
}

window.TableStakesLib.Core = (function() {
  function Core(options) {
    this._makeResizable = __bind(this._makeResizable, this);    this.utils = new window.TableStakesLib.Utils({
      core: this
    });
    this.events = new window.TableStakesLib.Events({
      core: this
    });
  }

  Core.prototype.set = function(options) {
    this.table = options.table;
    this.selection = options.selection;
    this.data = options.data;
    this.columns = this.table.columns();
    return this.headRows = this.table.headRows();
  };

  Core.prototype.update = function() {
    var _this = this;

    this.table.isInRender = true;
    return this.selection.call(function(selection) {
      return _this.table.update(selection);
    });
  };

  Core.prototype.render = function() {
    var wrap, wrapEnter;

    this._buildData();
    wrap = d3.select(this.table.el()).selectAll("div").data([[this.nodes]]);
    wrapEnter = wrap.enter().append("div");
    this.tableEnter = wrapEnter.append("table");
    this.tableObject = wrap.select("table").classed(this.table.tableClassName, true).attr("style", "table-layout:fixed;");
    if (this.table.header) {
      this._renderHead(this.tableObject);
    }
    this._renderBody(this.tableObject);
    if (this.table.isDraggable() !== false) {
      this._makeDraggable(this.tableObject);
    }
    if (this.table.isDeletable() !== false) {
      return this._makeDeletable(this.tableObject);
    }
  };

  Core.prototype._buildData = function() {
    var depth;

    if (!this.data[0]) {
      this.data[0] = {
        id: this.table.noData
      };
    }
    this.tree = d3.layout.tree().children(function(d) {
      return d.values;
    });
    this.nodes = this.tree.nodes(this.data[0]);
    depth = d3.max(this.nodes, function(node) {
      return node.depth;
    });
    return this.tree.size([this.table.height, depth * this.table.childIndent]);
  };

  Core.prototype._renderHead = function(tableObject) {
    var allTh, self, sortable, th, thead, theadRow,
      _this = this;

    self = this;
    thead = tableObject.selectAll('thead').data(function(d) {
      return d;
    }).enter().append('thead');
    if (!this.headRows) {
      theadRow = thead.append("tr");
      th = theadRow.selectAll("th").data(this.columns).enter().append("th").text(function(d) {
        return d.label;
      }).attr("ref", function(d, i) {
        return i;
      }).attr("class", function(d) {
        return _this._columnClasses(d);
      }).style('width', function(d) {
        return d.width;
      });
    } else {
      theadRow = thead.selectAll("thead").data(this.headRows).enter().append("tr").attr("class", function(d) {
        return d.headClasses;
      });
      th = theadRow.selectAll("th").data(function(row, i) {
        return row.col;
      }).enter().append("th").text(function(d) {
        if (!d.label) {
          d.classes += ' ' + 'underline';
        }
        return d.label;
      }).attr("ref", function(d, i) {
        return i;
      }).attr("class", function(d) {
        return _this._columnClasses(d);
      }).style('width', function(d) {
        return d.width;
      }).transition();
    }
    allTh = theadRow.selectAll("th");
    if (this.table.isResizable()) {
      this._makeResizable(allTh);
    }
    sortable = allTh.filter(function(d) {
      return d.isSortable;
    });
    this._makeSortable(sortable);
    return this;
  };

  Core.prototype._renderBody = function(tableObject) {
    this.tbody = tableObject.selectAll("tbody").data(function(d) {
      return d;
    });
    this.tbody.enter().append("tbody");
    return this._renderRows();
  };

  Core.prototype._enterRows = function() {
    var _this = this;

    return this.enterRows = this.rows.enter().append("tr").attr("class", function(d) {
      return _this._rowClasses(d);
    });
  };

  Core.prototype._updateRows = function() {
    var self;

    self = this;
    this.updateRows = this.rows.order();
    this._addRowEventHandling();
    return this.updateRows.select('.expandable').classed('folded', this.utils.folded);
  };

  Core.prototype._addRowEventHandling = function() {
    var addEvent, events,
      _this = this;

    events = {
      click: 'elementClick',
      dblclick: 'elementDblclick',
      mouseover: 'elementMouseover',
      mouseout: 'elementMouseout'
    };
    addEvent = function(key, value) {
      return _this.updateRows.on(key, function(d) {
        return _this.table.dispatch.elementClick({
          row: _this,
          data: d,
          pos: [d.x, d.y]
        });
      });
    };
    return _.each(events, function(value, key) {
      return addEvent(key, value);
    });
  };

  Core.prototype._exitRows = function() {
    return this.rows.exit().remove();
  };

  Core.prototype._renderRows = function() {
    this.rows = this.tbody.selectAll("tr").data((function(d) {
      return d;
    }), function(d) {
      return d.id;
    });
    this._enterRows();
    this._updateRows();
    this._exitRows();
    if (this.enterRows[0][0]) {
      d3.select(this.enterRows[0][0]).style("display", "none");
    }
    this._renderEnterRows();
    return this._renderUpdateRows();
  };

  Core.prototype._renderEnterRows = function() {
    var self,
      _this = this;

    self = this;
    return this.columns.forEach(function(column, column_index) {
      var text;

      text = function(d) {
        var index;

        if ((column.timeSeries != null) && (d.period != null) && (d.dataValue != null)) {
          index = d.period.indexOf(column.id);
          if (column.format) {
            return column.format(d.dataValue[index]);
          } else {
            return d.dataValue[index];
          }
        } else if (column.format) {
          return column.format(d);
        } else {
          return d[column.id] || '-';
        }
      };
      return _this.enterRows.append('td').attr('meta-key', column.id).attr('class', function(d) {
        return _this._cellClasses(d, column);
      }).html(text).each(function(d, i) {
        return self._renderCell(column, d, this);
      });
    });
  };

  Core.prototype._renderUpdateRows = function() {
    var self;

    self = this;
    return this.updateRows.selectAll('td').each(function(d, i) {
      if (self.columns[i] != null) {
        return self._renderCell(self.columns[i], d, this);
      }
    });
  };

  Core.prototype._renderCell = function(column, d, td) {
    var isEditable;

    isEditable = this.utils.ourFunctor(column.isEditable, d);
    if (this.utils.ourFunctor(column.isNested, d)) {
      this._makeNested(td);
    }
    if (isEditable) {
      this._makeEditable(d, td, column);
    }
    this._makeChanged(d, td, column);
    if (column.editor === 'boolean' && isEditable) {
      this._makeBoolean(d, td, column);
    }
    if (column.editor === 'select' && isEditable) {
      this._makeSelect(d, td, column);
    }
    if (column.editor === 'button' && isEditable) {
      this._makeButton(d, td, column);
    }
    if (column.showCount) {
      return this._addShowCount(d, td, column);
    }
  };

  Core.prototype._columnClasses = function(column) {
    if (typeof column.classes !== 'function') {
      return column.classes;
    }
  };

  Core.prototype._rowClasses = function(d) {
    if (this.table.rowClasses() != null) {
      return this.table.rowClasses()(d);
    }
  };

  Core.prototype._cellClasses = function(d, column) {
    var val;

    val = [];
    val.push(column.classes != null ? typeof column.classes === 'function' ? column.classes(d) : column.classes : void 0);
    if (column === this.columns[0]) {
      val.push(this.utils.nestedIcons(d));
    }
    if (d.classes != null) {
      val.push(d.classes);
    }
    return val.join(' ');
  };

  Core.prototype._makeDraggable = function(table) {
    var self,
      _this = this;

    self = this;
    if (table.selectAll('th.draggable-head')[0].length === 0) {
      table.selectAll("thead tr").append('th').attr('width', '15px').classed('draggable-head', true);
    }
    this.enterRows.append('td').classed('draggable', function(d) {
      return _this.utils.ourFunctor(_this.table.isDraggable(), d);
    });
    return this.updateRows.selectAll('td.draggable').on('mouseover', function(d) {
      return self._setDragBehavior();
    }).on('mouseout', function(d) {
      return self._clearDragBehavior();
    });
  };

  Core.prototype._setDragBehavior = function() {
    var dragBehavior, self;

    self = this;
    dragBehavior = d3.behavior.drag().origin(Object).on('dragstart', function(d, x, y) {
      return self.events.dragStart(this, d, x, y);
    }).on('drag', function(d, x, y) {
      return self.events.dragMove(this, d, x, y);
    }).on('dragend', function(d, x, y) {
      return self.events.dragEnd(this, d, x, y);
    });
    return this.updateRows.call(dragBehavior);
  };

  Core.prototype._clearDragBehavior = function() {
    var dragBehavior, self;

    self = this;
    dragBehavior = d3.behavior.drag().origin(Object).on('dragstart', null).on('drag', null).on('dragend', null);
    return this.updateRows.call(dragBehavior);
  };

  Core.prototype._makeDeletable = function(table) {
    var _this = this;

    if (table.selectAll('th.deletable-head')[0].length === 0) {
      table.selectAll("thead tr").append('th').attr('width', '15px').classed('deletable-head', true);
    }
    return this.enterRows.append('td').classed('deletable', function(d) {
      return _this.utils.ourFunctor(_this.table.isDeletable(), d);
    }).on('click', function(d) {
      if (_this.utils.ourFunctor(_this.table.isDeletable(), d)) {
        return _this.table.onDelete()(d.id);
      }
    });
  };

  Core.prototype._makeResizable = function(th) {
    var dragBehavior, handlers, removable, self;

    self = this;
    dragBehavior = d3.behavior.drag().on("drag", function() {
      return self.events.resizeDrag(this);
    });
    handlers = th.classed('resizeable', true).append("div").classed('resizeable-handle right', true).call(dragBehavior);
    removable = handlers[0] && handlers[0][handlers[0].length - 1] && handlers[0][handlers[0].length - 1].remove;
    if (removable) {
      return handlers[0][handlers[0].length - 1].remove();
    }
  };

  Core.prototype._makeSortable = function(allTh) {
    var desc, self, sorted;

    self = this;
    allTh.classed('sortable', true).append("div").classed('sortable-handle', true);
    sorted = allTh.filter(function(column) {
      return column.desc != null;
    });
    if (sorted[0] && sorted[0].length > 0) {
      desc = sorted.data()[0].desc;
      sorted.classed('sorted-asc', desc);
      sorted.classed('sorted-desc', !desc);
    }
    return allTh.on('click', function(a, b, c) {
      return self.events.toggleSort(this, a, b, c);
    });
  };

  Core.prototype._makeNested = function(td) {
    var _this = this;

    return d3.select(td).attr('class', function(d) {
      return _this.utils.nestedIcons(d);
    }).on('click', function(a, b, c) {
      return _this.events.nestedClick(_this, a, b, c);
    });
  };

  Core.prototype._makeEditable = function(d, td, column) {
    var eventType, self;

    self = this;
    if (_.contains(['boolean', 'select'], column.editor)) {
      return;
    }
    d3.select(td).classed('editable', true);
    if (column.editor === 'calendar') {
      d3.select(td).classed('calendar', true);
    }
    if (d.changed === column.id) {
      d3.select(td).classed('changed', true);
    }
    eventType = 'dblclick';
    d3.select(td).on(eventType, function(a, b, c) {
      return self.events.editableClick(this, a, b, c, column);
    });
    if (d.activatedID === column.id.toString()) {
      return this._makeActive(d, td, column);
    } else {
      return this._makeInactive(td);
    }
  };

  Core.prototype._makeActive = function(d, td, column) {
    var self, _text;

    self = this;
    _text = function(d) {
      if (_.has(column, 'timeSeries')) {
        return d.dataValue[_.indexOf(d.period, column.id)] || '-';
      } else {
        return d[column.id] || '-';
      }
    };
    return d3.select(td).classed('active', true).text(_text).attr('contentEditable', true).on('keydown', function(d) {
      return self.events.keydown(this, d, column);
    }).on('blur', function(d) {
      return self.events.blur(this, d, column);
    }).node().focus();
  };

  Core.prototype._makeInactive = function(node) {
    var self;

    self = this;
    return d3.select(node).classed('active', false).attr('contentEditable', false);
  };

  Core.prototype._makeChanged = function(d, td, column) {
    var i;

    if (d.changedID && (i = d.changedID.indexOf(column.id)) !== -1) {
      return d.changedID.splice(i, 1);
    }
  };

  Core.prototype._makeSelect = function(d, td, column) {
    var group, options, select,
      _this = this;

    options = this.utils.ourFunctor(column.selectOptions, d);
    select = d3.select(td).html('<select class="expand-select"></select>').select('.expand-select');
    select.append('option').style('cursor', 'pointer').text(d[column.id]);
    group = select.append('optgroup').style('cursor', 'pointer');
    _.each(_.without(options, d[column.id]), function(item) {
      return group.append('option').style('cursor', 'pointer').text(item);
    });
    return select.on('change', function(a, b, c) {
      return _this.events.selectClick(_this, a, b, c, column);
    });
  };

  Core.prototype._makeButton = function(d, td, column) {
    var classes, html, select,
      _this = this;

    classes = 'btn btn-mini btn-primary';
    html = "<input type='button' value='" + column.label + "' class='" + classes + "' />";
    return select = d3.select(td).html(html).on('click', function(a, b, c) {
      return _this.events.buttonClick(_this, a, b, c, column);
    });
  };

  Core.prototype._makeBoolean = function(d, td, column) {
    var _this = this;

    return d3.select(td).classed('boolean-true', d[column.id]).classed('boolean-false', !d[column.id]).on('click', function(a, b, c) {
      return _this.events.toggleBoolean(_this, a, b, c, column);
    });
  };

  Core.prototype._addShowCount = function(d, td, column) {
    var count, _ref, _ref1;

    count = ((_ref = d.values) != null ? _ref.length : void 0) || ((_ref1 = d._values) != null ? _ref1.length : void 0);
    return d3.select(td).append('span').classed('childrenCount', true).text(function(d) {
      if (count) {
        return '(' + count + ')';
      } else {
        return '';
      }
    });
  };

  return Core;

})();

}).call(this);

(function() {
  var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

window.TableStakes = (function() {
  TableStakes.prototype.id = Math.floor(Math.random() * 10000);

  TableStakes.prototype.header = true;

  TableStakes.prototype.noData = "No Data Available.";

  TableStakes.prototype.childIndent = 20;

  TableStakes.prototype.tableClassName = "tablestakes";

  TableStakes.prototype.gridData = [];

  TableStakes.prototype.gridFilteredData = [];

  TableStakes.prototype.tableObject = null;

  TableStakes.prototype.isInRender = false;

  TableStakes.prototype.filterCondition = [];

  TableStakes.prototype.dispatch = d3.dispatch("elementClick", "elementDblclick", "elementMouseover", "elementMouseout");

  TableStakes.prototype._minColumnWidth = 50;

  TableStakes.prototype._columns = [];

  TableStakes.prototype._margin = {
    top: 0,
    right: 0,
    bottom: 0,
    left: 0
  };

  function TableStakes(options) {
    var key;

    this.core = new window.TableStakesLib.Core;
    this._synthesize({
      data: [],
      el: null,
      isDeletable: false,
      onDelete: null,
      isResizable: true,
      isSortable: false,
      dragMode: null,
      isDraggable: false,
      onDrag: null,
      isDragDestination: true,
      rowClasses: null
    });
    this.filterCondition = d3.map([]);
    if (options != null) {
      for (key in options) {
        this.set(key, options[key]);
      }
    }
  }

  TableStakes.prototype.parseFlatData = function(flatData, key) {
    var data;

    data = [];
    _.each(_.keys(_.groupBy(flatData, function(obj) {
      return obj[key];
    })), function(productId, i) {
      return data.push({
        id: i,
        product_id: productId,
        period_id: _.chain(flatData).filter(function(obj) {
          return obj[key] === productId;
        }).map(function(obj) {
          return obj.period_id;
        }).value(),
        period: _.chain(flatData).filter(function(obj) {
          return obj[key] === productId;
        }).map(function(obj) {
          return obj.periodUnix;
        }).value(),
        dataValue: _.chain(flatData).filter(function(obj) {
          return obj[key] === productId;
        }).map(function(obj) {
          return obj.actual;
        }).value()
      });
    });
    this.data(data);
    return this;
  };

  TableStakes.prototype.render = function() {
    var _this = this;

    this.gridData = [
      {
        values: this.data()
      }
    ];
    this.columns().forEach(function(column, i) {
      return _this.gridData[0][column['id']] = column['id'];
    });
    this.setID(this.gridData[0], "0");
    this.gridFilteredData = this.gridData;
    this._setFilter(this.gridFilteredData[0], this.filterCondition);
    d3.select(this.el()).html('').datum(this.gridFilteredData).call(function(selection) {
      return _this.update(selection);
    });
    return this;
  };

  TableStakes.prototype.update = function(selection) {
    var _this = this;

    selection.each(function(data) {
      _this.core.set({
        selection: selection,
        table: _this,
        data: data
      });
      return _this.core.render();
    });
    this.isInRender = false;
    return this;
  };

  TableStakes.prototype.dispatchManualEvent = function(target) {
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

  TableStakes.prototype.setID = function(node, prefix) {
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

  TableStakes.prototype.sort = function(columnId, isDesc) {
    var sortFunction;

    if (!((columnId != null) || (isDesc != null))) {
      return;
    }
    sortFunction = function(a, b) {
      if ((a[columnId] != null) && (b[columnId] != null)) {
        if (isDesc) {
          if (a[columnId].toUpperCase() > b[columnId].toUpperCase()) {
            return 1;
          } else {
            return -1;
          }
        } else {
          if (a[columnId].toUpperCase() < b[columnId].toUpperCase()) {
            return 1;
          } else {
            return -1;
          }
        }
      } else {
        return 0;
      }
    };
    this.data().sort(sortFunction);
    return this.render();
  };

  TableStakes.prototype.filter = function(key, value) {
    value = value || '';
    value = value.toString().toUpperCase();
    this.filterCondition.set(key, value);
    this._setFilter(this.gridFilteredData[0], this.filterCondition);
    return this.render();
  };

  TableStakes.prototype._setFilter = function(data, filter) {
    var i, key, matchFound, self, _data, _i, _j, _k, _len, _ref, _ref1, _ref2;

    self = this;
    data || (data = []);
    if (typeof data._hiddenvalues === "undefined") {
      data['_hiddenvalues'] = [];
    }
    if (data.values) {
      data.values = data.values.concat(data._hiddenvalues);
      data._hiddenvalues = [];
      for (i = _i = _ref = data.values.length - 1; _i >= 0; i = _i += -1) {
        if (this._setFilter(data.values[i], filter) === null) {
          data._hiddenvalues.push(data.values.splice(i, 1)[0]);
        }
      }
    }
    if (data._values) {
      data._values = data._values.concat(data._hiddenvalues);
      data._hiddenvalues = [];
      for (i = _j = _ref1 = data._values.length - 1; _j >= 0; i = _j += -1) {
        if (this._setFilter(data._values[i], filter) === null) {
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
        _data = data[key].toUpperCase();
        if (_data.indexOf(filter.get(key)) === -1) {
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

  TableStakes.prototype.get = function(key) {
    return this[key];
  };

  TableStakes.prototype.set = function(key, value, options) {
    if (key != null) {
      this[key] = (value != null ? value : true);
    }
    return this;
  };

  TableStakes.prototype.is = function(key) {
    if (this[key]) {
      return true;
    } else {
      return false;
    }
  };

  TableStakes.prototype.margin = function(val) {
    var side, _i, _len, _ref;

    if (val == null) {
      return this._margin;
    }
    _ref = ['top', 'right', 'bottom', 'left'];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      side = _ref[_i];
      if (typeof val[side] !== "undefined") {
        this._margin[side] = val[side];
      }
    }
    return this;
  };

  TableStakes.prototype.columns = function(columnList) {
    var _this = this;

    if (!columnList) {
      return this._columns;
    }
    this._columns = [];
    _.each(columnList, function(column) {
      var c, grouppedItems, groupper, i, item, _column, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2, _ref3, _results, _results1, _results2;

      if (column.timeSeries) {
        if (column.timeSeries.length <= 12) {
          _ref = column.timeSeries;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            item = _ref[_i];
            _column = _.clone(column);
            if (column.label != null) {
              _column.id = item;
              _column.label = typeof column.label === 'function' ? column.label(item) : column.label;
            } else {
              _column.id = item;
              _column.label = new Date(item).toGMTString().split(' ')[2];
              _column.secondary = new Date(item).getFullYear().toString();
            }
            c = new window.TableStakesLib.Column(_column);
            _results.push(_this._columns.push(c));
          }
          return _results;
        } else if ((12 < (_ref1 = column.timeSeries.length) && _ref1 <= 36)) {
          groupper = 3;
          _ref2 = column.timeSeries;
          _results1 = [];
          for ((groupper > 0 ? (i = _j = 0, _len1 = _ref2.length) : i = _j = _ref2.length - 1); groupper > 0 ? _j < _len1 : _j >= 0; i = _j += groupper) {
            item = _ref2[i];
            grouppedItems = _.first(column.timeSeries.slice(i), groupper);
            _column = _.clone(column);
            _column.id = [_.first(grouppedItems), _.last(grouppedItems)].join('-');
            if (grouppedItems.length > 1) {
              _column.label = [new Date(_.first(grouppedItems)).toGMTString().split(' ')[2], new Date(_.last(grouppedItems)).toGMTString().split(' ')[2]].join(' - ');
            } else {
              _column.label = new Date(_.first(grouppedItems)).toGMTString().split(' ')[2];
            }
            _column.secondary = new Date(_.last(grouppedItems)).getFullYear().toString();
            if (i === 0) {
              _column.secondary = new Date(_.first(grouppedItems)).getFullYear().toString();
            }
            c = new window.TableStakesLib.Column(_column);
            _results1.push(_this._columns.push(c));
          }
          return _results1;
        } else {
          groupper = 12;
          _ref3 = column.timeSeries;
          _results2 = [];
          for ((groupper > 0 ? (i = _k = 0, _len2 = _ref3.length) : i = _k = _ref3.length - 1); groupper > 0 ? _k < _len2 : _k >= 0; i = _k += groupper) {
            item = _ref3[i];
            grouppedItems = _.first(column.timeSeries.slice(i), groupper);
            _column = _.clone(column);
            _column.id = [_.first(grouppedItems), _.last(grouppedItems)].join('-');
            if (new Date(_.first(grouppedItems)).getMonth() === 0) {
              _column.label = "              " + (new Date(_.first(grouppedItems)).getFullYear());
            } else if (grouppedItems.length > 1) {
              _column.label = "              " + (new Date(_.first(grouppedItems)).getMonth() + 1) + "/              " + (new Date(_.first(grouppedItems)).getFullYear()) + " -              " + (new Date(_.last(grouppedItems)).getMonth() + 1) + "/              " + (new Date(_.last(grouppedItems)).getFullYear());
            } else {
              _column.label = "              " + (new Date(_.first(grouppedItems)).getMonth() + 1) + "/              " + (new Date(_.first(grouppedItems)).getFullYear());
            }
            c = new window.TableStakesLib.Column(_column);
            _results2.push(_this._columns.push(c));
          }
          return _results2;
        }
      } else {
        c = new window.TableStakesLib.Column(column);
        return _this._columns.push(c);
      }
    });
    return this;
  };

  TableStakes.prototype.headRows = function(filter) {
    var row, visiblePeriod, _columns;

    if (filter == null) {
      return this._headRows;
    }
    this._headRows = [];
    if (_.filter(this._columns, function(col) {
      return _.has(col, filter);
    }).length > 0) {
      _columns = [];
      _.each(this._columns, function(col) {
        var c;

        c = _.clone(col);
        if (_.has(col, filter)) {
          c.label = col[filter];
        } else {
          c.label = "";
        }
        return _columns.push(c);
      });
      row = new window.TableStakesLib.HeadRow({
        col: _columns,
        headClasses: filter
      });
    } else {
      row = new window.TableStakesLib.HeadRow({
        col: []
      });
    }
    if (_.filter(this._columns, function(col) {
      return _.has(col, 'timeSeries');
    }).length > 0) {
      visiblePeriod = [];
      _.each(row.col, function(column, i) {
        var begin, end, hidden;

        hidden = 'hidden';
        if (column.timeSeries != null) {
          if ((column.classes == null) || column.classes.indexOf(hidden) === -1) {
            if (_.isNumber(column.id)) {
              return visiblePeriod.push(column.id);
            } else if (_.isString(column.id)) {
              begin = parseInt(column.id.split('-')[0]);
              end = parseInt(column.id.split('-')[1]);
              return _.each(column.timeSeries, function(date) {
                if ((begin <= date && date <= end)) {
                  return visiblePeriod.push(date);
                }
              });
            }
          }
        }
      });
      _.each(row.col, function(column, i) {
        var begin, end, filtered, first;

        filtered = _.filter(visiblePeriod, function(date) {
          return (new Date(date)).getFullYear().toString() === column.label;
        });
        first = _.first(filtered);
        if (!first) {
          first = _.first(visiblePeriod);
        }
        if (_.isString(column.id)) {
          begin = parseInt(column.id.split('-')[0]);
          end = parseInt(column.id.split('-')[1]);
          if (!((begin <= first && first <= end))) {
            return column.label = "";
          }
        } else if (column.id !== first) {
          return column.label = "";
        }
      });
    }
    this._headRows.push(row);
    this._headRows.push(new window.TableStakesLib.HeadRow({
      col: this._columns
    }));
    return this;
  };

  TableStakes.prototype.displayColumns = function(periods, show) {
    var hideColumns;

    hideColumns = function(columns, periods, show) {
      _.each(columns, function(column, i) {
        var hidden, i1, i2, _ref;

        if (!!column.timeSeries && (_ref = column.id, __indexOf.call(periods, _ref) < 0)) {
          hidden = 'hidden';
          if (!column.classes) {
            column.classes = '';
          }
          i1 = column.classes.indexOf(hidden);
          i2 = 'hidden'.length;
          if (!show) {
            if (i1 === -1) {
              return column.classes += ' ' + hidden;
            }
          } else {
            if (i1 !== -1) {
              return column.classes = column.classes.replace(hidden, '');
            }
          }
        }
      });
      return this;
    };
    if (typeof periods === 'string') {
      periods = [periods];
    }
    if (periods.length === 0) {
      periods = _.chain(this._columns).filter(function(col) {
        return !!col.timeSeries;
      }).pluck('timeSeries').first().first(12).value();
    }
    if (show == null) {
      show = true;
    }
    hideColumns(this._columns, periods, show);
    return this;
  };

  TableStakes.prototype.dataAggregate = function(filter) {
    var data, summ, timeFrame;

    summ = function(data, availableTimeFrame) {
      var groupper, _data, _ref;

      _data = [];
      if (availableTimeFrame.length <= 12) {
        return data;
      } else if ((12 < (_ref = availableTimeFrame.length) && _ref <= 36)) {
        groupper = 3;
      } else {
        groupper = 12;
      }
      _.each(data, function(row, i) {
        var end, j, start, val, _dataValue, _i, _j, _len, _len1, _period, _period_id, _slicePeriod, _slicePeriodId, _sliceValue;

        _period = [];
        _period_id = [];
        _dataValue = [];
        start = _.indexOf(row.period, _.first(availableTimeFrame));
        end = _.indexOf(row.period, _.last(availableTimeFrame));
        if (!(start === -1 || end === -1)) {
          _slicePeriod = row.period.length ? row.period.slice(start, end + 1) : [];
          _slicePeriodId = row.period_id.length ? row.period_id.slice(start, end + 1) : [];
          _sliceValue = row.dataValue.length ? row.dataValue.slice(start, end + 1) : [];
          for ((groupper > 0 ? (j = _i = 0, _len = _slicePeriod.length) : j = _i = _slicePeriod.length - 1); groupper > 0 ? _i < _len : _i >= 0; j = _i += groupper) {
            val = _slicePeriod[j];
            _period.push([val, _.last(_slicePeriod.slice(j, j + groupper))].join('-'));
            _period_id.push([_.first(_slicePeriodId.slice(j, j + groupper)), _.last(_slicePeriodId.slice(j, j + groupper))].join('-'));
            _dataValue.push(_.reduce(_sliceValue.slice(j, j + groupper), function(memo, num) {
              if (_.isNumber(num) && _.isNumber(memo)) {
                return memo + num;
              } else {
                return '-';
              }
            }, 0));
          }
        } else {
          for ((groupper > 0 ? (j = _j = 0, _len1 = availableTimeFrame.length) : j = _j = availableTimeFrame.length - 1); groupper > 0 ? _j < _len1 : _j >= 0; j = _j += groupper) {
            val = availableTimeFrame[j];
            _period.push([val, _.last(availableTimeFrame.slice(j, +(j + groupper) + 1 || 9e9))].join('-'));
            _period_id.push([_.first(row.period_id.slice(j, j + groupper)), _.last(row.period_id.slice(j, j + groupper))].join('-'));
            _dataValue.push('-');
          }
        }
        return _data.push({
          id: i,
          product_id: row.product_id,
          period_id: _period_id,
          period: _period,
          dataValue: _dataValue
        });
      });
      return _data;
    };
    data = this.data();
    timeFrame = _.find(this._columns, function(obj) {
      return obj.timeSeries != null;
    }).timeSeries;
    if (_.isFunction(filter)) {
      return this;
    } else if (filter === 'sum') {
      this.data(summ(data, timeFrame));
    }
    return this;
  };

  TableStakes.prototype._synthesize = function(hash) {
    var _this = this;

    return _.each(hash, function(value, key) {
      var func;

      _this['_' + key] = value;
      func = function(key) {
        return _this[key] = function(val) {
          if (val == null) {
            return this['_' + key];
          }
          this['_' + key] = val;
          return this;
        };
      };
      return func(key);
    });
  };

  return TableStakes;

})();

}).call(this);

(function() {
  if (!window.TableStakesLib) {
  window.TableStakesLib = {};
}

window.TableStakesLib.Utils = (function() {
  function Utils(options) {
    this.core = options.core;
  }

  Utils.prototype.getCurrentColumnIndex = function(id) {
    var col, currentindex, i, _i, _len, _ref;

    currentindex = this.core.columns.length;
    _ref = this.core.columns;
    for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
      col = _ref[i];
      if (col.id === id) {
        currentindex = i;
        break;
      }
    }
    return currentindex;
  };

  Utils.prototype.findEditableColumn = function(d, currentIndex, isNext) {
    var column, condition, nextIndex;

    if (isNext) {
      condition = currentIndex < this.core.columns.length;
      nextIndex = currentIndex + 1;
    } else {
      condition = currentIndex >= 0;
      nextIndex = currentIndex - 1;
    }
    if (condition) {
      column = this.core.columns[currentIndex];
      if (column.isEditable) {
        if (typeof column.isEditable === 'boolean') {
          return currentIndex;
        } else if (column.isEditable(d, column)) {
          return currentIndex;
        } else {
          return this.findEditableColumn(d, nextIndex, isNext);
        }
      } else {
        return this.findEditableColumn(d, nextIndex, isNext);
      }
    } else {
      return null;
    }
  };

  Utils.prototype.findEditableCell = function(d, column, isNext) {
    var isBoolean, node;

    if (isNext) {
      node = this.core.utils.findNextNode(d);
    } else {
      node = this.core.utils.findPrevNode(d);
    }
    if (node != null) {
      if (column.isEditable) {
        isBoolean = typeof column.isEditable === 'boolean';
        if (isBoolean || column.isEditable(node, column)) {
          return node;
        } else {
          return this.findEditableCell(node, column, isNext);
        }
      }
    }
  };

  Utils.prototype.findNextNode = function(d) {
    var i, idPath, leaf, nextNodeID, root, _i, _j, _len, _ref, _ref1;

    nextNodeID = null;
    _ref = this.core.nodes;
    for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
      leaf = _ref[i];
      if (leaf._id === d._id) {
        if (this.core.nodes.length !== i + 1) {
          nextNodeID = this.core.nodes[i + 1]._id;
        }
        break;
      }
    }
    if (nextNodeID === null) {
      return null;
    }
    idPath = nextNodeID.split("_");
    root = this.core.data[0];
    for (i = _j = 1, _ref1 = idPath.length - 1; 1 <= _ref1 ? _j <= _ref1 : _j >= _ref1; i = 1 <= _ref1 ? ++_j : --_j) {
      root = root.values[parseInt(idPath[i])];
    }
    return root;
  };

  Utils.prototype.findPrevNode = function(d) {
    var i, idPath, leaf, prevNodeID, root, _i, _j, _len, _ref, _ref1;

    prevNodeID = null;
    _ref = this.core.nodes;
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
    root = this.core.data[0];
    for (i = _j = 1, _ref1 = idPath.length - 1; 1 <= _ref1 ? _j <= _ref1 : _j >= _ref1; i = 1 <= _ref1 ? ++_j : --_j) {
      root = root.values[parseInt(idPath[i])];
    }
    return root;
  };

  Utils.prototype.removeNode = function(d) {
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
    return this.core.table.setID(parent, parent._id);
  };

  Utils.prototype.appendNode = function(d, child) {
    if (d.values) {
      d.values.push(child);
    } else if (d._values) {
      d._values.push(child);
    } else {
      d.values = [child];
    }
    return this.core.table.setID(d, d._id);
  };

  Utils.prototype.pastNode = function(d, child) {
    var array, index, n, _i, _len, _ref;

    n = 0;
    array = [];
    _ref = d.parent.values;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      index = _ref[_i];
      array[n] = index;
      n = n + 1;
      if (d === index) {
        array[n] = child;
        n = n + 1;
      }
    }
    d.parent.values = array;
    return this.core.table.setID(d.parent, d.parent._id);
  };

  Utils.prototype.findNodeByID = function(id) {
    var i, idPath, root, _i, _ref;

    idPath = id.split("_");
    root = this.core.table.gridFilteredData[0];
    for (i = _i = 1, _ref = idPath.length - 1; 1 <= _ref ? _i <= _ref : _i >= _ref; i = 1 <= _ref ? ++_i : --_i) {
      root = root.values[parseInt(idPath[i])];
    }
    return root;
  };

  Utils.prototype.deactivateAll = function(d) {
    var _this = this;

    d.activatedID = null;
    if (d.values) {
      d.values.forEach(function(item, index) {
        return _this.core.utils.deactivateAll(item);
      });
    }
    if (d._values) {
      d._values.forEach(function(item, index) {
        return _this.core.utils.deactivateAll(item);
      });
    }
  };

  Utils.prototype.hasChildren = function(d) {
    var values;

    values = d.values || d._values;
    return values && values.length;
  };

  Utils.prototype.isChild = function(child, parent) {
    var d, u, values, _i, _len;

    u = this.core.utils;
    if (u.hasChildren(parent)) {
      values = parent.values || parent._values;
      for (_i = 0, _len = values.length; _i < _len; _i++) {
        d = values[_i];
        if (d === child) {
          return true;
        }
        if (u.hasChildren(d) && u.isChild(child, d)) {
          return true;
        }
      }
    }
    return false;
  };

  Utils.prototype.isParent = function(parent, child) {
    var values;

    if (this.core.utils.hasChildren(parent)) {
      values = parent.values || parent._values;
      return _.contains(values, child);
    } else {
      return false;
    }
  };

  Utils.prototype.folded = function(d) {
    return d._values && d._values.length;
  };

  Utils.prototype.nestedIcons = function(d) {
    var indent;

    if ((d.depth - 1) < 6) {
      indent = d.depth - 1;
    } else {
      indent = 5;
    }
    if (d._values && d._values.length) {
      return 'expandable' + ' ' + 'indent' + indent;
    } else if (d.values && d.values.length) {
      return 'collapsible' + ' ' + 'indent' + indent;
    } else {
      return 'indent' + (indent + 1);
    }
  };

  Utils.prototype.ourFunctor = function(attr, element, etc) {
    if (typeof attr === 'function') {
      return attr(element, etc);
    } else {
      return attr;
    }
  };

  return Utils;

})();

}).call(this);

