"use strict"

Hope    = require("zenserver").Hope
Schema  = require("zenserver").Mongoose.Schema
db      = require("zenserver").Mongo.connections.primary
# C       = require "../constants"

VideoSubmit = new Schema
  user        : type: Schema.ObjectId, ref: "User"
  url         : type: String
  created_at  : type: Date, default: Date.now

VideoSubmit.statics.register = (attributes) ->
  promise = new Hope.Promise()
  @create attributes, (error, result) ->
    promise.done(error, result)
  promise

module.exports = db.model "Video-submit", VideoSubmit
