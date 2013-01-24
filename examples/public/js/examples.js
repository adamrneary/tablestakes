// Generated by CoffeeScript 1.4.0
var core, prepareLinks, showcaseObject;

core = [
  {
    shortLink: "base",
    title: "Base example"
  }, {
    shortLink: "editable",
    title: "Editable"
  }, {
    shortLink: "nested",
    title: "Nested"
  }, {
    shortLink: "filterable",
    title: "Filterable"
  }, {
    shortLink: "add-and-delete",
    title: "Add and delete"
  }, {
    shortLink: "dragable",
    title: "Dragable"
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
    var script, url;
    $("#example_header").text(route.title);
    url = "js/" + route.shortLink + ".js";
    script = $("<script>").attr("src", url);
    $("#example_view").empty().append(script);
    console.log('url', url);
    $.get(url, function(data) {
      $("#example_js").text(data);
      $('.example').hide();
      eval(data);
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