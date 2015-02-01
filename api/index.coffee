"use strict"

Hope        = require("zenserver").Hope
Video       = require "../common/models/video"

PAGINATION  = 24

CHANNELS =
  javascript: ["javascript"]
  ruby      : ["ruby"]
  python    : ["python"]
  database  : ["sql", "mongodb", "redis", "hadoop", "raabbitmq", "mysql", "postgresql", "nosql", "db"]
  nodejs    : ["nodejs"]
  design    : ["css"]
  languages : ["coffeescript", "dart", "typescript", "clojure", "scala"]
  mobile    : ["android", "ios", "mobile"]

module.exports = (server) ->

  server.get "/api/index", (request, response) ->
    page = request.parameters.page
    explore = request.parameters.explore
    tag = request.parameters.tag
    author = request.parameters.author
    channel = request.parameters.channel
    filter = active: true
    filter.tags = $in: [tag] if tag
    filter["author.name"] = author if author
    filter.tags = $in: CHANNELS[channel] if channel
    __videos response, filter, PAGINATION, page


  server.get "/api/search", (request, response) ->
    page = request.parameters.page
    field = new RegExp request.parameters.query, "i"
    filter =
      active        : true
      $or : [
        title       : field
      ,
        description : field
      ,
        tags        : field
      ]
    __videos response, filter, PAGINATION, page


# -- Private -------------------------------------------------------------------
__videos = (response, filter={}, limit, page, sort) ->
  Video.search(filter, limit, page, sort).then (error, videos) ->
    if error
      response.badRequest()
    else
      response.json videos: (video.parse() for video in videos)
