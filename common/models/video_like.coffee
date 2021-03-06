"use strict"

Hope    = require("zenserver").Hope
Schema  = require("zenserver").Mongoose.Schema
db      = require("zenserver").Mongo.connections.primary
# C       = require "../constants"

VideoLike = new Schema
  user        : type: Schema.ObjectId, ref: "User"
  video       : type: Schema.ObjectId, ref: "Video"
  created_at  : type: Date, default: Date.now

VideoLike.statics.register = (attributes) ->
  promise = new Hope.Promise()
  @findOne(attributes).exec (error, result) =>
    return promise.done error, result if result
    @create attributes, (error, result) -> promise.done(error, result)
  promise

VideoLike.statics.search = (query={}, limit=0, page=1) ->
  promise = new Hope.Promise()
  range =  if page > 1 then limit * (page - 1) else 0
  @find(query).skip(range).limit(limit).sort(created_at: "desc").exec (error, value) ->
    if limit is 1
      error = code: 402, message: "Video not found." if value.length is 0
      value = value[0] if value.length isnt 0
    promise.done error, value
  promise

VideoLike.statics.byUser = (user) ->
  promise = new Hope.Promise()
  @find(user: user, "video -_id").exec (error, values) ->
    videos = []
    videos.push value.video for value in (values or [])
    promise.done null, videos
  promise

VideoLike.methods.parse = ->
  video         : @video
  created_at    : @created_at

module.exports = db.model "Video-like", VideoLike
