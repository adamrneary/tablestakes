// Generated by CoffeeScript 1.4.0
var core, prepareLinks, showcaseObject;

core = [
  {
    shortLink: "base",
    title: "Base example"
  }, {
    shortLink: "custom_classes",
    title: "Custom classes"
  }, {
    shortLink: "editable",
    title: "Editable"
  }, {
    shortLink: "nested",
    title: "Nested"
  }, {
    shortLink: "nested_editable",
    title: "Nested and editable"
  }, {
    shortLink: "filterable",
    title: "Filterable"
  }, {
    shortLink: "deleteable",
    title: "Deleteable"
  }, {
    shortLink: "resizable",
    title: "Resizable"
  }, {
    shortLink: "hierarchy_dragging",
    title: "Hierarchy dragging"
  }, {
    shortLink: "reorder_dragging",
    title: "Reorder dragging"
  }, {
    shortLink: "editors",
    title: "Custom editors"
  }, {
    shortLink: "timeseries",
    title: "Timeseries"
  }, {
    shortLink: "all",
    title: "Full stack"
  }
];

showcaseObject = {
  routes: {}
};

prepareLinks = function(route, el) {
  var link;
  link = $("<a>").attr("href", "/#" + route.shortLink).text(route.title);
  el.append($("<li>").append(link));
  showcaseObject.routes[route.shortLink] = route.shortLink;
  return showcaseObject[route.shortLink] = function() {
    var script, url, urlCoffee;
    $("#example_header").text(route.title);
    urlCoffee = "coffee/" + route.shortLink + ".coffee";
    url = "js/" + route.shortLink + ".js";
    script = $("<script>").attr("src", url);
    $("#example_view").empty().append(script);
    $("#temp").empty();
    $.get(urlCoffee, function(data) {
      return $("#example_js").text(data);
    });
    $.get(url, function(data) {
      return $("example_view").text(data);
    });
    $("#example_js").load(urlCoffee, function() {
      $(this).removeClass("rainbow");
      return Rainbow.color();
    });
    return Rainbow.color();
  };
};

$(document).ready(function() {
  var Showcase, showcase;
  _.map(core, function(route) {
    return prepareLinks(route, $("#coreLinkList"));
  });
  Showcase = Backbone.Router.extend(showcaseObject);
  showcase = new Showcase();
  Backbone.history.start();
  if (!window.location.hash) {
    return showcase.navigate("/#base");
  }
});
