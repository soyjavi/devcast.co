"use strict"

Hope    = require("zenserver").Hope
Schema  = require("zenserver").Mongoose.Schema
db      = require("zenserver").Mongo.connections.primary
# C       = require "../constants"

USER =
  ROLE:
    CUSTOMER: 0
    SUPPORT : 1
    ADMIN   : 2

User = new Schema
  appnima           :
    id              : type: String
    mail            : type: String
    password        : type: String
    name            : type: String
    avatar          : type: String
    access_token    : type: String
    refresh_token   : type: String
    user_agent      : type: String
    expire          : type: Date
  updated_at        : type: Date
  created_at        : type: Date, default: Date.now

User.statics.signup = (appnima) ->
  promise = new Hope.Promise()
  @findOne(appnima: appnima.mail).exec (error, value) ->
    return promise.done true if value?
    properties = appnima: appnima
    user = db.model "User", User
    new user(properties).save (error, value) -> promise.done error, value
  promise

User.statics.login = (appnima) ->
  promise = new Hope.Promise()
  filter  = "appnima.id": appnima.id
  properties = appnima: appnima
  options = upsert: true
  @findOneAndUpdate filter, properties, options, (error, result) ->
    error = code: 404, message: "User not found." if not result?
    promise.done error, result
  promise

User.statics.search = (query) ->
  promise = new Hope.Promise()
  @find(query).exec (error, result) -> promise.done error, result
  promise

User.statics.searchOne = (query) ->
  promise = new Hope.Promise()
  @findOne(query).exec (error, result) -> promise.done error, result
  promise

User.statics.findAndUpdate = (filter, parameters) ->
  promise = new Hope.Promise()
  parameters.updated_at = new Date()
  @findOneAndUpdate filter, parameters, (error, result) ->
    promise.done error, result
  promise

User.methods.parse = ->
  id        : @_id.toString()
  mail      : @appnima.mail
  name      : @appnima.name
  avatar    : @appnima.avatar
  phone     : @appnima.phone
  token     : @appnima.access_token
  appnima   : @appnima.id
  expire    : @appnima.expire
  created_at: @created_at

exports = module.exports = db.model "User", User
