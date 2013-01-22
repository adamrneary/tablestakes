/*! tablestakes - v0.0.1 - 2013-01-22
* https://github.com/activecell/tablestakes
* Copyright (c) 2013 Activecell; Licensed  */

var Table;

Tablestakes.Table = Table = (function() {

  function Table() {}

  Table.prototype.margin = {
    top: 0,
    right: 0,
    bottom: 0,
    left: 0
  };

  Table.prototype.width = 960;

  Table.prototype.height = 500;

  Table.prototype.id = Math.floor(Math.random() * 10000);

  Table.prototype.header = true;

  Table.prototype.noData = "No Data Available.";

  Table.prototype.childIndent = 20;

  Table.prototype.columns = [
    {
      key: "key",
      label: "Name",
      type: "text"
    }
  ];

  Table.prototype.tableClassName = "class";

  Table.prototype.iconOpenImg = "images/expand.gif";

  Table.prototype.iconCloseImg = "images/collapse.gif";

  Table.prototype.dispatch = d3.dispatch("elementClick", "elementDblclick", "elementMouseover", "elementMouseout");

  Table.prototype.columnResize = true;

  Table.prototype.isSortable = true;

  Table.prototype.isEditable = true;

  Table.prototype.gridData = [];

  Table.prototype.tableObject = null;

  Table.prototype.minWidth = 50;

  Table.prototype.tableWidth = 0;

  Table.prototype.isInRender = false;

  Table.prototype.dispatchManualEvent = function(target) {
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

  Table.prototype.render = function(_) {
    var self, setID;
    self = this;
    this.gridData = [
      {
        values: this.gridData
      }
    ];
    this.columns.forEach(function(column, i) {
      return self.gridData[0][column['key']] = column['key'];
    });
    setID = function(node, prefix) {
      node['_id'] = prefix;
      if (node.values) {
        node.values.forEach(function(subnode, i) {
          return setID(subnode, prefix + "_" + i);
        });
      }
      if (node._values) {
        return node._values.forEach(function(subnode, i) {
          return setID(subnode, prefix + "_" + i);
        });
      }
    };
    setID(self.gridData[0], "0");
    d3.select(_).datum(self.gridData).call(function(__) {
      return self.doRendering(__);
    });
    return this;
  };

  Table.prototype.calculateTableWidth = function() {
    var width;
    width = 0;
    this.columns.forEach(function(column, index) {
      return width += parseInt(column.width);
    });
    this.tableWidth = width;
    return width;
  };

  Table.prototype.doRendering = function(selection) {
    var drag, editCell, self;
    self = this;
    drag = d3.behavior.drag().on("drag", function(d, i) {
      var column_newX, column_x, index, table_newX, table_x, th;
      th = d3.select(this).node().parentNode;
      column_x = parseFloat(d3.select(th).attr("width"));
      column_newX = d3.event.x;
      if (self.minWidth < column_newX) {
        d3.select(th).attr("width", column_newX + "px");
        index = parseInt(d3.select(th).attr("ref"));
        self.columns[index].width = column_newX + "px";
        table_x = parseFloat(self.tableObject.attr("width"));
        table_newX = table_x + (column_newX - column_x);
        return self.tableObject.attr("width", table_newX + "px");
      }
    });
    editCell = function(d, i) {
      var cell, columnKey, htmlContent;
      cell = d3.select(this);
      htmlContent = d3.select(this).text();
      columnKey = d3.select(this)[0][0].parentNode.getAttribute("ref");
      d3.select(this).text("");
      d3.select(this).append("input").attr("type", "text").attr("value", htmlContent).on("keydown", function() {
        /*
                  nextCell = null
                  if d3.event.keyCode == 9                                                         # tab key down
                    d3.event.preventDefault()
                    d3.event.stopPropagation()
                    if d3.event.shiftKey == false                                                  # if shiftkey is not pressed, get next 
                      nextCell = cell.node().parentNode.nextSibling
                      if nextCell == null
                        nextCell = cell.node().parentNode.parentNode.nextSibling
                      if nextCell != null
                        nextCell = d3.select(nextCell).selectAll(".name").node()
                    else                                                                           # if shiftkey is not pressed, get previous
                      nextCell = cell.node().parentNode.previousSibling
                      if nextCell == null
                        nextCell = cell.node().parentNode.parentNode.previousSibling
                      if nextCell != null
                        prevRow = d3.select(nextCell).selectAll(".name")[0]
                        nextCell = prevRow[prevRow.length-1]
                  else if d3.event.keyCode == 38                                                   # upward key pressed 
                    nextRow = cell.node().parentNode.parentNode.previousSibling
                    console.log(d, i)
                  else if d3.event.keyCode == 40                                                   # downward key pressed
                    nextRow = cell.node().parentNode.parentNode.nextSibling
                    console.log(d, i)
                  if nextCell != null
                    self.dispatchManualEvent nextCell
                  return
        */

      }).on("keyup", function() {
        /*
                  switch d3.event.keyCode
                    when 13 # enter key down
                      cell.text(d3.select(this).node().value)
                      d[columnKey]=d3.select(this).node().value              
                    when 27 # escape key down
                      d3.select(this).node().value = d[columnKey]
                      cell.text(d[columnKey])
                  return
        */

      }).on("blur", function() {
        cell.text(d3.select(this).node().value);
        return d[columnKey] = d3.select(this).node().value;
      }).node().focus();
    };
    selection.each(function(data) {
      var click, dblclick, depth, findNextNode, findPrevNode, folded, getCurrentColumnIndex, hasChildren, i, icon, keydown, keyup, node, nodeEnter, nodes, table, tableEnter, tbody, thead, theadRow1, tree, update, wrap, wrapEnter;
      getCurrentColumnIndex = function(id) {
        var col, currentindex, i, _i, _len, _ref;
        currentindex = self.columns.length;
        _ref = self.columns;
        for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
          col = _ref[i];
          if (col.key === id) {
            currentindex = i;
            break;
          }
        }
        return currentindex;
      };
      findNextNode = function(d, nodes) {
        var i, idPath, leaf, nextNodeID, root, _i, _j, _len, _ref;
        nextNodeID = null;
        for (i = _i = 0, _len = nodes.length; _i < _len; i = ++_i) {
          leaf = nodes[i];
          if (leaf._id === d._id) {
            if (nodes.length !== i + 1) {
              nextNodeID = nodes[i + 1]._id;
            }
            break;
          }
        }
        if (nextNodeID === null) {
          return null;
        }
        idPath = nextNodeID.split("_");
        root = self.gridData[0];
        for (i = _j = 1, _ref = idPath.length - 1; 1 <= _ref ? _j <= _ref : _j >= _ref; i = 1 <= _ref ? ++_j : --_j) {
          root = root.values[parseInt(idPath[i])];
        }
        return root;
      };
      findPrevNode = function(d, nodes) {
        var i, idPath, leaf, prevNodeID, root, _i, _j, _len, _ref;
        prevNodeID = null;
        for (i = _i = 0, _len = nodes.length; _i < _len; i = ++_i) {
          leaf = nodes[i];
          if (leaf._id === d._id) {
            break;
          }
          prevNodeID = leaf._id;
        }
        if (prevNodeID === null) {
          return null;
        }
        if (prevNodeID === "0") {
          return null;
        }
        idPath = prevNodeID.split("_");
        root = self.gridData[0];
        for (i = _j = 1, _ref = idPath.length - 1; 1 <= _ref ? _j <= _ref : _j >= _ref; i = 1 <= _ref ? ++_j : --_j) {
          root = root.values[parseInt(idPath[i])];
        }
        return root;
      };
      keydown = function(d, nodes) {
        var currentindex, nextCell, nextNode, prevNode;
        nextCell = null;
        if (d3.event.keyCode === 9) {
          d3.event.preventDefault();
          d3.event.stopPropagation();
          currentindex = getCurrentColumnIndex(d.activatedID);
          if (d3.event.shiftKey === false) {
            if (currentindex < self.columns.length - 1) {
              d.activatedID = self.columns[currentindex + 1].key;
            } else {
              nextNode = findNextNode(d, nodes);
              if (nextNode !== null) {
                nextNode.activatedID = self.columns[0].key;
                d.activatedID = null;
              }
            }
          } else {
            if (currentindex > 0) {
              d.activatedID = self.columns[currentindex - 1].key;
            } else {
              prevNode = findPrevNode(d, nodes);
              if (prevNode !== null) {
                prevNode.activatedID = self.columns[self.columns.length - 1].key;
                d.activatedID = null;
              }
            }
          }
          update();
        } else if (d3.event.keyCode === 38) {
          prevNode = findPrevNode(d, nodes);
          currentindex = getCurrentColumnIndex(d.activatedID);
          if (prevNode !== null) {
            prevNode.activatedID = self.columns[currentindex].key;
            d.activatedID = null;
          }
          update();
        } else if (d3.event.keyCode === 40) {
          nextNode = findNextNode(d, nodes);
          currentindex = getCurrentColumnIndex(d.activatedID);
          if (nextNode !== null) {
            nextNode.activatedID = self.columns[currentindex].key;
            d.activatedID = null;
          }
          update();
        }
      };
      keyup = function(d, nodes) {
        switch (d3.event.keyCode) {
          case 13:
            console.log("enterkey");
            d.activatedID = null;
            update();
            break;
          case 27:
            console.log("escape");
            d3.select(this).node().value = d[d.activatedID];
            d.activatedID = null;
            update();
        }
      };
      click = function(d, _, unshift) {
        d3.event.stopPropagation();
        if (d3.event.shiftKey && !unshift) {
          d3.event.shiftKey = false;
          d.values && d.values.forEach(function(node) {
            if (node.values || node._values) {
              return click(node, 0, true);
            }
          });
          return true;
        }
        if (!hasChildren(d)) {
          return true;
        }
        if (d.values) {
          d._values = d.values;
          d.values = null;
        } else {
          d.values = d._values;
          d._values = null;
        }
        return update();
      };
      dblclick = function(d, _, unshift) {
        var DeactivateAll;
        DeactivateAll = function(d) {
          d.activatedID = null;
          if (d.values) {
            d.values.forEach(function(item, index) {
              return DeactivateAll(item);
            });
          }
          if (d._values) {
            d._values.forEach(function(item, index) {
              return DeactivateAll(item);
            });
          }
        };
        DeactivateAll(data[0]);
        d.activatedID = d3.select(d3.select(this).node().parentNode).attr("meta-key");
        return update();
      };
      icon = function(d) {
        if (d._values && d._values.length) {
          return self.iconOpenImg;
        } else {
          if (d.values && d.values.length) {
            return self.iconCloseImg;
          } else {
            return "";
          }
        }
      };
      folded = function(d) {
        return d._values && d._values.length;
      };
      hasChildren = function(d) {
        var values;
        values = d.values || d._values;
        return values && values.length;
      };
      i = 0;
      depth = 1;
      tree = d3.layout.tree().children(function(d) {
        return d.values;
      }).size([self.height, self.childIndent]);
      update = function() {
        self.isInRender = true;
        return selection.transition().call(function(_) {
          return self.doRendering(_);
        });
      };
      if (!data[0]) {
        data[0] = {
          key: noData
        };
      }
      nodes = tree.nodes(data[0]);
      wrap = d3.select(this).selectAll("div").data([[nodes]]);
      wrapEnter = wrap.enter().append("div").attr("class", "nvd3 nv-wrap nv-indentedtree");
      tableEnter = wrapEnter.append("table");
      self.tableWidth = self.calculateTableWidth();
      table = wrap.select("table").attr("class", self.tableClassName).attr("style", "table-layout:fixed;").attr("width", self.tableWidth + "px");
      self.tableObject = table;
      if (self.header) {
        thead = tableEnter.append("thead");
        theadRow1 = thead.append("tr");
        self.columns.forEach(function(column, i) {
          var th;
          th = theadRow1.append("th").attr("width", (column.width ? column.width : "100px")).attr("ref", i).style("text-align", (column.type === "numeric" ? "right" : "left"));
          th.append("span").text(column.label);
          if (self.columnResize) {
            th.style("position", "relative");
            return th.append("div").attr("class", "table-resizable-handle").text('&nbsp;').call(drag);
          }
        });
      }
      tbody = table.selectAll("tbody").data(function(d) {
        return d;
      });
      tbody.enter().append("tbody");
      depth = d3.max(nodes, function(node) {
        return node.depth;
      });
      tree.size([self.height, depth * self.childIndent]);
      node = tbody.selectAll("tr").data(function(d) {
        return d;
      }, function(d) {
        return d.id || (d.id === ++i);
      });
      node.exit().remove();
      node.select("img.nv-treeicon").attr("src", function(d) {
        return icon(d);
      }).classed("folded", folded);
      nodeEnter = node.enter().append("tr");
      if (nodeEnter[0][0]) {
        d3.select(nodeEnter[0][0]).style("display", "none");
      }
      self.columns.forEach(function(column, index) {
        var nodeName;
        nodeName = nodeEnter.append("td").attr("meta-key", column.key).style("padding-left", function(d) {
          return (index ? 0 : (d.depth - 1) * self.childIndent + (icon(d) ? 0 : 16)) + "px";
        }, "important").style("text-align", (column.type === "numeric" ? "right" : "left")).attr("ref", column.key);
        if (index === 0) {
          nodeName.append("img").classed("nv-treeicon", true).classed("nv-folded", folded).attr("src", function(d) {
            return icon(d);
          }).style("width", "14px").style("height", "14px").style("padding", "0 1px").style("display", function(d) {
            if (icon(d)) {
              return "inline-block";
            } else {
              return "none";
            }
          }).on("click", click);
        }
        nodeName.each(function(td) {
          if (td.activatedID === column.key) {
            return d3.select(this).append("span").attr("class", d3.functor(column.classes)).append("input").attr('type', 'text').attr('value', function(d) {
              return d[column.key] || "";
            }).on("keydown", function(d) {
              return keydown(d, nodes);
            }).on("keyup", keyup).on("blur", function(d) {
              d[column.key] = d3.select(this).node().value;
              if (self.isInRender === false) {
                d.activatedID = null;
                return update();
              }
            }).node().focus();
          } else {
            return d3.select(this).append("span").attr("class", d3.functor(column.classes)).text(function(d) {
              if (column.format) {
                return column.format(d);
              } else {
                return d[column.key] || "-";
              }
            });
          }
        });
        if (column.showCount) {
          nodeName.append("span").attr("class", "nv-childrenCount").text(function(d) {
            if ((d.values && d.values.length) || (d._values && d._values.length)) {
              return "(" + ((d.values && d.values.length) || (d._values && d._values.length)) + ")";
            } else {
              return "";
            }
          });
        }
        if (self.isEditable) {
          return nodeName.select("span").on("dblclick", dblclick);
        }
      });
      return node.order().on("click", function(d) {
        return self.dispatch.elementClick({
          row: this,
          data: d,
          pos: [d.x, d.y]
        });
      }).on("dblclick", function(d) {
        return self.dispatch.elementDblclick({
          row: this,
          data: d,
          pos: [d.x, d.y]
        });
      }).on("mouseover", function(d) {
        return self.dispatch.elementMouseover({
          row: this,
          data: d,
          pos: [d.x, d.y]
        });
      }).on("mouseout", function(d) {
        return self.dispatch.elementMouseout({
          row: this,
          data: d,
          pos: [d.x, d.y]
        });
      });
    });
    this.isInRender = false;
    return this;
  };

  Table.prototype.data = function(_) {
    if (!_) {
      return this.gridData;
    }
    this.gridData = _;
    return this;
  };

  Table.prototype.margin = function(_) {
    if (!_) {
      return this.margin;
    }
    this.margin.top = (typeof _.top !== "undefined" ? _.top : this.margin.top);
    this.margin.right = (typeof _.right !== "undefined" ? _.right : this.margin.right);
    this.margin.bottom = (typeof _.bottom !== "undefined" ? _.bottom : this.margin.bottom);
    return this.margin.left = (typeof _.left !== "undefined" ? _.left : this.margin.left);
  };

  Table.prototype.columnReize = function(_) {
    if (_ == null) {
      return this.columnResize;
    }
    this.columnResize = _;
    return this;
  };

  Table.prototype.editable = function(_) {
    if (_ == null) {
      return this.isEditable;
    }
    this.isEditable = _;
    return this;
  };

  Table.prototype.width = function(_) {
    if (_ == null) {
      return width;
    }
    this.width = _;
    return this;
  };

  Table.prototype.height = function(_) {
    if (_ == null) {
      return this.height;
    }
    this.height = _;
    return this;
  };

  Table.prototype.color = function(_) {
    if (_ == null) {
      return this.color;
    }
    this.color = _;
    return this;
  };

  Table.prototype.id = function(_) {
    if (_ == null) {
      return this.id;
    }
    this.id = _;
    return this;
  };

  Table.prototype.header = function(_) {
    if (_ == null) {
      return this.header;
    }
    this.header = _;
    return this;
  };

  Table.prototype.noData = function(_) {
    if (_ == null) {
      return this.noData;
    }
    this.noData = _;
    return this;
  };

  Table.prototype.columns = function(_) {
    if (_ == null) {
      return this.columns;
    }
    this.columns = _;
    return this;
  };

  Table.prototype.tableClass = function(_) {
    if (_ == null) {
      return this.tableClass;
    }
    this.tableClass = _;
    return this;
  };

  Table.prototype.iconOpen = function(_) {
    if (_ == null) {
      return this.iconOpen;
    }
    this.iconOpen = _;
    return this;
  };

  Table.prototype.iconClose = function(_) {
    if (_ == null) {
      return this.iconClose;
    }
    this.iconClose = _;
    return this;
  };

  Table.prototype.Sortable = function(_) {
    if ((_ != null)) {
      this.isSortable = _;
      return this;
    } else {
      return this.isSortable;
    }
  };

  return Table;

})();
