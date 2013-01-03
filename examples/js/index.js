var core = [
{
  shortLink: "base", 
  title: "Base example"
},
{
  shortLink: "nested", 
  title: "Nested"
},
{
  shortLink: "filterable", 
  title: "Filterable"
},
{
  shortLink: "add-and-delete", 
  title: "Add and delete"
}
];

var showcaseObject = {
  routes: {}
};


var prepareLinks = function(route, el) {
  var link = $("<a>")
  .attr("href", "/#" + route.shortLink)
  .text(route.title);
  el.append($("<li>").append(link));
  showcaseObject.routes[route.shortLink] = route.shortLink;
  showcaseObject[route.shortLink] = function() {
    $("#example_header").text(route.title);
    var url = "javascript/" + route.shortLink + ".js";
    var script = $("<script>").attr("src", url);
    $("#example_view").empty().append(script);
        
    $("#example_js").load(url, function() {
      $(this).removeClass("rainbow");
      Rainbow.color();
    });
    Rainbow.color();
  };
}

$(document).ready(function() {
  _.map(core, function(route) {
    prepareLinks(route, $("#coreLinkList"));
  });

  var Showcase = Backbone.Router.extend(showcaseObject);
  var showcase = new Showcase();

  Backbone.history.start();
  if (!window.location.hash) {
    showcase.navigate("/#line");
  }
});