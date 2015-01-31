"use strict"

class Atoms.Organism.App extends Atoms.Organism.Article

  @url: "/scaffold/article.app.json"

  constructor: ->
    super
    do @render
    do @fetchVideos

  # -- Children Bubble Events --------------------------------------------------
  onInputKeyup: (event, atom) ->
    input = atom.value()
    if input.length >= 2
      @fetchVideos @page = 0, @filter = query: input, "search"

  onChannel: (event, button) ->
    key = button.attributes.text.toLowerCase()
    filter = channel: key if key isnt "home"
    @fetchVideos @page = 0, filter, @context = "index"

  onVideoSelect: (atom) ->
    console.log  atom.entity

  onSectionScroll: (event) ->
    # super
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
