"use strict"

class Atoms.Organism.App extends Atoms.Organism.Article

  @url: "/scaffold/article.app.json"

  constructor: ->
    super
    do @render
    url = Atoms.Url.path().split("/")
    @filter = if url[1]? and url[1] is "channel" then channel: url[2] else {}
    @fetchVideos @page = 0, @filter
    for child in @channels.children when child.attributes.text.toLowerCase() is @filter.channel
      child.el.addClass("active").siblings().removeClass("active")
      break

  # -- Children Bubble Events --------------------------------------------------
  onInputKeyup: (event, atom) ->
    input = atom.value()
    if input.length >= 2 and not @fetching
      @fetchVideos @page = 0, @filter = query: input, "search"

  onChannel: (event, button) ->
    key = button.attributes.text.toLowerCase()
    if key isnt "home"
      Atoms.Url.path "channel/#{key}"
      filter = channel: key
    else
      Atoms.Url.path ""
    @fetchVideos @page = 0, filter, @context = "index"

  onVideoSelect: (atom) ->
    window.location = "/#{atom.entity.id}"

  onSectionScroll: (event) ->
    super
    if event.down and event.percent > 75 and not @fetching
      @fetchVideos @page = @page + 1, @filter

  # -- Private Events ----------------------------------------------------------
  fetchVideos: (@page = 0, @filter = {}, @context = "index") ->
    @fetching = true
    __.Entity.Video.destroyAll() if @page is 0
    parameters = page: @page
    parameters.tag = @filter.tag if @filter.tag
    parameters.author = @filter.author if @filter.author
    parameters.channel = @filter.channel if @filter.channel
    parameters.query = @filter.query if @filter.query
    __.proxy("GET", @context, parameters).then (error, response) =>
      __.Entity.Video.create video for video in response?.videos
      @fetching = false
