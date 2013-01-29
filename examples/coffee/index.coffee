core = [
  shortLink: "base"
  title: "Base example"
,
  shortLink: "editable"
  title: "Editable"
,
  shortLink: "nested"
  title: "Nested"
,
  shortLink: "filterable"
  title: "Filterable"
,
  shortLink: "add-and-delete"
  title: "Add and delete"
,    
  shortLink: "resizable",
  title: "Resizable"
,
  shortLink: "hierarchy_dragging"
  title: "Hierarchy dragging"
]

showcaseObject = routes: {}
prepareLinks = (route, el) ->
  link = $("<a>").attr("href", "/#" + route.shortLink).text(route.title)
  el.append $("<li>").append(link)
  showcaseObject.routes[route.shortLink] = route.shortLink
  showcaseObject[route.shortLink] = ->
    $("#example_header").text route.title
    url = "js/" + route.shortLink + ".js"
    script = $("<script>").attr("src", url)
    $("#example_view").empty().append script
    console.log 'url',url
    $.get url, (data)->
        $("#example_js").text data
        $('.example').hide()
        eval data
        $(this).removeClass "rainbow"
        Rainbow.color()
    Rainbow.color()

$(document).ready ->
  _.map core, (route) ->
    prepareLinks route, $("#coreLinkList")

  Showcase = Backbone.Router.extend(showcaseObject)
  showcase = new Showcase()
  Backbone.history.start()

  showcase.navigate "/#base"  unless window.location.hash


