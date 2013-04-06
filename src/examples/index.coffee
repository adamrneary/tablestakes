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
    url       = "js/" + route.shortLink + ".js"
    script    = $("<script>").attr("src", url)

    $("#temp").empty().append script

    $.get urlCoffee, (data) ->
      $("#example_js").text(data).removeClass("rainbow")
      console.log 'color'
      Rainbow.color()


$(document).ready ->
  _.map core, (route) ->
    prepareLinks route, $("#coreLinkList")

  Showcase = Backbone.Router.extend(showcaseObject)
  showcase = new Showcase()
  Backbone.history.start()

  showcase.navigate "/#base"  unless window.location.hash
