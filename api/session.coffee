"use strict"

Hope      = require("zenserver").Hope
Redis     = require("zenserver").Redis
Appnima   = require("zenserver").Appnima
User      = require "../common/models/user"
VideoLike = require "../common/models/video_like"
VideoView = require "../common/models/video_view"
Session   = require "../common/session"

module.exports = (server) ->

  server.post "/api/login", (request, response) ->
    if request.required ['mail', 'password']
      mail = request.parameters.mail
      if mail.indexOf("@") < 0
        delete request.parameters.mail
        request.parameters.username = mail

      Hope.shield([ ->
        Appnima.login request.parameters
      , (error, appnima) ->
        User.login appnima
      ]).then (error, user) ->
        if error then response.unauthorized() else response.json user.parse()

  server.post "/api/signup", (request, response) ->
    if request.required ['mail', 'password']
      Hope.shield([->
        Appnima.signup request.parameters
      , (error, appnima) ->
        User.signup appnima
      ]).then (error, user) ->
        if error
          response.json message: error.message, error.code
        else
          response.json user.parse()

  server.get "/api/session", (request, response) ->
    Session(request, response).then (error, session) ->
      Redis.run "SMEMBERS", "WATCHLATER:#{session.id}", (error, redis) ->
        Hope.join([ ->
          VideoView.byUser session
        , ->
          VideoLike.byUser session
        ]).then (errors, values) ->
          response.json
            watchlater: redis or []
            views     : values[0] or []
            likes     : values[1] or []
