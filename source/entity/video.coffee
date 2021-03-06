"use strict"

class __.Entity.Video extends Atoms.Class.Entity

  @fields "id", "title", "description", "image", "embed", "duration",
          "author", "language", "tags", "type", "level", "views",
          "created_at"

  parse: ->
    style       : @tags[0]
    title       : @title
    description : @description or false
    image       : @image
    tags        : (@tags[i] for i in [0..2] when @tags[i])
    duration    : @duration
    when        : moment(@created_at).fromNow()
    views       : @views
