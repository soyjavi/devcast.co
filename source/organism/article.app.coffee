"use strict"

class Atoms.Organism.App extends Atoms.Organism.Article

  @url: "/scaffold/article.app.json"

  constructor: ->
    super
    do @render
    do @fetchVideos

  # -- Children Bubble Events --------------------------------------------------
  onSectionScroll: (event) ->
    if event.down and event.percent > 75 and not @fetching
      @fetchVideos @page = @page + 1

  onVideoSelect: (atom) ->
    console.log  atom.entity

  # -- Private Events ----------------------------------------------------------
  fetchVideos: (@page = 0, context) ->
    @fetching = true
    __.Entity.Video.destroyAll() if @page is 0
    parameters = page: @page
    __.proxy("GET", "index", parameters).then (error, response) =>
      @fetching = false
      __.Entity.Video.create video for video in response?.videos
