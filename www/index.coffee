"use strict"

Hope        = require("zenserver").Hope
Redis       = require("zenserver").Redis
Video       = require("../common/models/video")

module.exports = (zen) ->

  zen.get "/channel/:context", (request, response) ->
    response.page "base", page: "index"

  zen.get "/:video", (request, response) ->
    if request.parameters.video.length > 0
      Hope.shield([->
        Video.search _id: request.parameters.video, limit = 1
      , (error, @video) =>
        Video.attributes @video._id, views: @video.views + 1
      ]).then (error, value) =>
        unless error
          key = "VIEWS:TODAY:#{@video.id}"
          Redis.run "INCR", key
          Redis.run "EXPIRE", key, (60 * 60 * 24)
          bindings =
            page          : "video"
            title         : "#{@video.title} - devcast.co"
            video         : @video.parse()
            meta:
              title       : " - #{@video.title}"
              description : @video.description
          response.page "base", bindings, ["partial.video"]
        else
          response.redirect "/"
    else
      response.page "base", page: "index"
