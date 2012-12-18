(function() {

  window.TablesStakes = (function() {

    function TablesStakes() {}

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

    TablesStakes.prototype.iconOpenImg = "images/expand.gif";

    TablesStakes.prototype.iconCloseImg = "images/collapse.gif";

    TablesStakes.prototype.dispatch = d3.dispatch("elementClick", "elementDblclick", "elementMouseover", "elementMouseout");

    TablesStakes.prototype.columnResize = true;

    TablesStakes.prototype.isEditable = true;

    TablesStakes.prototype.gridData = [];

    TablesStakes.prototype.tableObject = null;

    TablesStakes.prototype.minWidth = 50;

    TablesStakes.prototype.tableWidth = 0;

    TablesStakes.prototype.render = function(_) {
      var self;
      self = this;
      d3.select(_).datum(self.gridData).call(function(__) {
        return self.doRendering(__);
      });
      return this;
    };

    TablesStakes.prototype.calculateTableWidth = function() {
      var width;
      width = 0;
      this.columns.forEach(function(column, index) {
        return width += parseInt(column.width);
      });
      this.tableWidth = width;
      return width;
    };

    TablesStakes.prototype.doRendering = function(selection) {
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
        htmlContent = d3.select(this).html();
        columnKey = d3.select(this)[0][0].parentNode.getAttribute("ref");
        d3.select(this).html("");
        return d3.select(this).append("input").attr("type", "text").attr("value", htmlContent).on("blur", function() {
          cell.html(d3.select(this).node().value);
          return d[columnKey] = d3.select(this).node().value;
        }).node().focus();
      };
      selection.each(function(data) {
        var click, depth, folded, hasChildren, i, icon, node, nodeEnter, nodes, table, tableEnter, tbody, thead, theadRow1, tree, update, wrap, wrapEnter;
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
              return th.append("div").attr("class", "table-resizable-handle").text('-').call(drag);
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
        self.columns.forEach(function(column, index) {
          var nodeName;
          nodeName = nodeEnter.append("td").style("padding-left", function(d) {
            return (index ? 0 : d.depth * self.childIndent + 12 + (icon(d) ? 0 : 16)) + "px";
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
          nodeName.append("span").attr("class", d3.functor(column.classes)).text(function(d) {
            if (column.format) {
              return column.format(d);
            } else {
              return d[column.key] || "-";
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
            return nodeName.select("span").on("dblclick", editCell);
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
      return this;
    };

    TablesStakes.prototype.data = function(_) {
      if (!_) {
        return this.gridData;
      }
      this.gridData = _;
      return this;
    };

    TablesStakes.prototype.margin = function(_) {
      if (!_) {
        return this.margin;
      }
      this.margin.top = (typeof _.top !== "undefined" ? _.top : this.margin.top);
      this.margin.right = (typeof _.right !== "undefined" ? _.right : this.margin.right);
      this.margin.bottom = (typeof _.bottom !== "undefined" ? _.bottom : this.margin.bottom);
      return this.margin.left = (typeof _.left !== "undefined" ? _.left : this.margin.left);
    };

    TablesStakes.prototype.header = function(_) {
      if (!_) {
        return this.columnResize;
      }
      this.columnResize = _;
      return this;
    };

    TablesStakes.prototype.width = function(_) {
      if (!_) {
        return width;
      }
      this.width = _;
      return this;
    };

    TablesStakes.prototype.height = function(_) {
      if (!_) {
        return this.height;
      }
      this.height = _;
      return this;
    };

    TablesStakes.prototype.id = function(_) {
      if (!_) {
        return this.id;
      }
      this.id = _;
      return this;
    };

    TablesStakes.prototype.header = function(_) {
      if (!_) {
        return this.header;
      }
      this.header = _;
      return this;
    };

    TablesStakes.prototype.noData = function(_) {
      if (!_) {
        return this.noData;
      }
      this.noData = _;
      return this;
    };

    TablesStakes.prototype.columns = function(_) {
      if (!_) {
        return this.columns;
      }
      this.columns = _;
      this.calculateTableWidth();
      return this;
    };

    TablesStakes.prototype.tableClass = function(_) {
      if (!_) {
        return this.tableClass;
      }
      this.tableClass = _;
      return this;
    };

    TablesStakes.prototype.iconOpen = function(_) {
      if (!_) {
        return this.iconOpen;
      }
      this.iconOpen = _;
      return this;
    };

    TablesStakes.prototype.iconClose = function(_) {
      if (!_) {
        return this.iconClose;
      }
      this.iconClose = _;
      return this;
    };

    return TablesStakes;

  })();

}).call(this);
