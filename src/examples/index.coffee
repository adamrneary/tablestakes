core = [
  shortLink: "base"
  title: "Base example"
,
  shortLink: "custom_classes"
  title: "Custom classes"
,
  shortLink: "editable"
  title: "Editable"
,
  shortLink: "sortable"
  title: "Sortable"
,
  shortLink: "nested"
  title: "Nested"
,
  shortLink: "nested_editable"
  title: "Nested and editable"
,
  shortLink: "filterable"
  title: "Filterable"
,
  shortLink: "deleteable"
  title: "Deleteable"
,
  shortLink: "resizable",
  title: "Resizable"
,
  shortLink: "hierarchy_dragging"
  title: "Hierarchy dragging"
,
  shortLink: "reorder_dragging"
  title: "Reorder dragging"
,
  shortLink: "editors"
  title: "Custom editors"
,
  shortLink: "select_options"
  title: "Select Options"
,
  shortLink: "timeseries"
  title: "Timeseries"
,
  shortLink: "all"
  title: "Full stack"
]

showcaseObject = routes: {}
prepareLinks = (route, el) ->
  link = $("<a>").attr("href", "/#" + route.shortLink).text(route.title)
  el.append $("<li>").append(link)
  showcaseObject.routes[route.shortLink] = route.shortLink
  showcaseObject[route.shortLink] = ->
    $("#example_header").text route.title
    urlCoffee = "examples/" + route.shortLink + ".coffee"
    url       = "examples/" + route.shortLink + ".js"

    $.get urlCoffee, (data) ->
      $("#example_js").text(data).removeClass("rainbow")
      Rainbow.color()
      source = CoffeeScript.compile(data)
      $("#example_code").remove()
      $('body').append $("<script id='example_code'>#{source}</script>")

#NOTE name of test should be same, as name of function
#additional fields will be passed to function as options object
tests = [
  name: 'testInit'
  rows: 36
  columns: 12
,
  name: 'testUpdate'
  rows: 72
  columns: 24
,
  name: 'testRender'
]

$(document).ready ->
  if location.pathname is '/'
    _.map core, (route) ->
      prepareLinks route, $("#coreLinkList")

    Showcase = Backbone.Router.extend(showcaseObject)
    showcase = new Showcase()
    Backbone.history.start()

    showcase.navigate "/#base"  unless window.location.hash

  else if location.pathname is '/performance'
    perf = new Performance
      el: $('<div id="performance" />').appendTo('#content')
      tests: tests
