"use strict"

Hope        = require("zenserver").Hope
Redis       = require("zenserver").Redis
Appnima     = require("zenserver").Appnima
User        = require "../common/models/user"
Video       = require "../common/models/video"
VideoLike   = require "../common/models/video_like"
VideoView   = require "../common/models/video_view"
VideoSubmit = require "../common/models/video_submit"
Session     = require "../common/session"

PAGINATION  = 30

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
    profile = request.parameters.profile
    explore = request.parameters.explore
    if profile
      __profile response, profile, page
    else if explore
      __explore response, explore, page
    else
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


  server.post "/api/submit", (request, response) ->
    Session(response).then (error, session) ->
      attributes =
        user: session
        url : request.parameters.url
      VideoSubmit.register(attributes).then (error, value) ->
        response.successful()


  server.post "/api/like", (request, response) ->
    response.required ['video']

    Session(response).then (error, session) ->
      attributes =
        user : session
        video: request.parameters.video
      VideoLike.register(attributes).then (error, value) ->
        response.successful()


  server.post "/api/watchlater", (request, response) ->
    response.required ['video']

    Session(response).then (error, session) ->
      if session
        video = request.parameters.video
        key = "WATCHLATER:#{session.id}"
        Redis.run "SADD", key, video
        Redis.run "EXPIRE", key, (60 * 60 * 24 * 14)
        response.successful()
      else
        response.unauthorized()

# -- Private -------------------------------------------------------------------
__videos = (response, filter={}, limit, page, sort) ->
  Video.search(filter, limit, page, sort).then (error, videos) ->
    if error
      response.badRequest()
    else
      response.json videos: (video.parse() for video in videos)

__profile = (response, context, page) ->
  Session(response).then (error, session) ->
    range =  if page > 1 then PAGINATION * (page - 1) else 0

    if context is "likes"
      VideoLike.find(user: session).skip(range).limit(PAGINATION).sort(created_at: "desc").populate("video").exec (error, likes) ->
        response.json videos: (like.video.parse() for like in (likes or []))
    else if context is "history"
      VideoView.find(user: session).skip(range).limit(PAGINATION).sort(created_at: "desc").populate("video").exec (error, views) ->
        response.json videos: (view.video.parse() for view in (views or []))
    else
      Redis.run "SMEMBERS", "WATCHLATER:#{session.id}", (error, redis) ->
        filter =
          active: true
          _id   : $in: redis
        __videos response, filter, PAGINATION, page

__explore = (response, context, page) ->
  if context is "most_viewed"
    filter = active: true
    __videos response, filter, PAGINATION, page, sort = views: "desc"
  else if context is "hot"
    redis_key =  "VIEWS:TODAY:"
    Redis.run "SCAN", "0", "match", "#{redis_key}*", (error, redis) =>
      filter =
        active: true
        _id   : $in: (key.replace(redis_key, "") for key in redis[1] or [])
      __videos response, filter, PAGINATION, page, sort = created_at: "desc"
