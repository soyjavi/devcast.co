"use strict"

Yoi         = require "yoi"
User        = require "../models/user"
Video       = require "../models/video"
VideoLike   = require "../models/video_like"
VideoView   = require "../models/video_view"
VideoSubmit = require "../models/video_submit"
Session     = require "../session"

PAGINATION  = 30

CHANNELS =
  javascript: ["javascript"]
  ruby      : ["ruby"]
  python    : ["python"]
  database  : ["sql", "mongodb", "redis", "hadoop", "raabbitmq", "mysql", "postgresql", "nosql", "db"]
  node_js   : ["nodejs"]
  design    : ["css"]
  languages : ["coffeescript", "dart", "typescript", "clojure", "scala"]
  mobile    : ["android", "ios", "mobile"]

module.exports = (server) ->

  server.post "/devcast/login", (request, response) ->
    rest = new Yoi.Rest request, response
    rest.required ['mail', 'password']

    agent       = request.headers['user-agent']
    mail        = rest.parameter "mail"
    password    = rest.parameter "password"
    Yoi.Hope.shield([->
      Yoi.Appnima.login agent, mail, password
    , (error, appnima) ->
      User.login appnima
    ]).then (error, user) ->
      return rest.exception(error.code, error.message) if error
      rest.run token: user.parse().token


  server.post "/devcast/signup", (request, response) ->
    rest = new Yoi.Rest request, response
    rest.required ['mail', 'password']

    agent       = request.headers["user-agent"]
    mail        = rest.parameter "mail"
    password    = rest.parameter "password"
    Yoi.Hope.shield([->
      Yoi.Appnima.signup agent, mail, password
    , (error, appnima) ->
      User.signup appnima
    ]).then (error, user) ->
      return rest.exception(error.code, error.message) if error
      rest.run user.parse()


  server.get "/devcast/session", (request, response) ->
    rest = new Yoi.Rest request, response
    Session(rest).then (error, session) ->
      return rest.unauthorized() unless session
      Yoi.Redis.run "SMEMBERS", "WATCHLATER:#{session.id}", (error, redis) ->
        Yoi.Hope.join([ ->
          VideoView.byUser session
        , ->
          VideoLike.byUser session
        ]).then (errors, values) ->
          rest.run
            watchlater: redis or []
            views     : values[0] or []
            likes     : values[1] or []


  server.get "/devcast/index", (request, response) ->
    rest = new Yoi.Rest request, response
    page = rest.parameter "page"
    profile = rest.parameter "profile"
    explore = rest.parameter "explore"
    if profile
      __profile rest, profile, page
    else if explore
      __explore rest, explore, page
    else
      tag = rest.parameter "tag"
      author = rest.parameter "author"
      channel = rest.parameter "channel"
      filter = active: true
      filter.tags = $in: [tag] if tag
      filter["author.name"] = author if author
      filter.tags = $in: CHANNELS[channel] if channel
      __videos rest, filter, PAGINATION, page


  server.get "/devcast/search", (request, response) ->
    rest = new Yoi.Rest request, response
    page = rest.parameter("page")
    field = new RegExp rest.parameter("query"), "i"
    filter =
      active        : true
      $or : [
        title       : field
      ,
        description : field
      ,
        tags        : field
      ]
    __videos rest, filter, PAGINATION, page


  server.post "/devcast/submit", (request, response) ->
    rest = new Yoi.Rest request, response
    Session(rest).then (error, session) ->
      attributes =
        user: session
        url : rest.parameter "url"
      VideoSubmit.register(attributes).then (error, value) ->
        rest.successful()


  server.post "/devcast/like", (request, response) ->
    rest = new Yoi.Rest request, response
    rest.required ['video']

    Session(rest).then (error, session) ->
      attributes =
        user : session
        video: rest.parameter "video"
      VideoLike.register(attributes).then (error, value) ->
        rest.successful()


  server.post "/devcast/watchlater", (request, response) ->
    rest = new Yoi.Rest request, response
    rest.required ['video']

    Session(rest).then (error, session) ->
      if session
        video = rest.parameter "video"
        key = "WATCHLATER:#{session.id}"
        Yoi.Redis.run "SADD", key, video
        Yoi.Redis.run "EXPIRE", key, (60 * 60 * 24 * 14)
        rest.successful()
      else
        rest.unauthorized()

# Private
__videos = (rest, filter={}, limit, page, sort) ->
  Video.search(filter, limit, page, sort).then (error, videos) ->
    if error
      rest.badRequest()
    else
      rest.run videos: (video.parse() for video in videos)

__profile = (rest, context, page) ->
  Session(rest).then (error, session) ->
    range =  if page > 1 then PAGINATION * (page - 1) else 0

    if context is "likes"
      VideoLike.find(user: session).skip(range).limit(PAGINATION).sort(created_at: "desc").populate("video").exec (error, likes) ->
        rest.run videos: (like.video.parse() for like in (likes or []))
    else if context is "history"
      VideoView.find(user: session).skip(range).limit(PAGINATION).sort(created_at: "desc").populate("video").exec (error, views) ->
        rest.run videos: (view.video.parse() for view in (views or []))
    else
      Yoi.Redis.run "SMEMBERS", "WATCHLATER:#{session.id}", (error, redis) ->
        filter =
          active: true
          _id   : $in: redis
        __videos rest, filter, PAGINATION, page

__explore = (rest, context, page) ->
  if context is "most_viewed"
    filter = active: true
    __videos rest, filter, PAGINATION, page, sort = views: "desc"
  else if context is "hot"
    redis_key =  "VIEWS:TODAY:"
    Yoi.Redis.run "SCAN", "0", "match", "#{redis_key}*", (error, redis) =>
      filter =
        active: true
        _id   : $in: (key.replace(redis_key, "") for key in redis[1] or [])
      __videos rest, filter, PAGINATION, page, sort = created_at: "desc"
