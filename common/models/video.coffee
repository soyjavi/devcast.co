"use strict"

Hope    = require("zenserver").Hope
Schema  = require("zenserver").Mongoose.Schema
db      = require("zenserver").Mongo.connections.primary
# C       = require "../constants"

Video = new Schema
  provider    : type: Number
  reference   : type: String, unique: true
  url         : type: String
  title       : type: String
  description : type: String
  image       : type: String
  embed       : type: String
  duration    : type: Number
  tags        : [type: String]
  type        : type: Number
  language    : type: String
  author      : type: Object
  active      : type: Boolean, default: true
  level       : type: Number, default: 0
  views       : type: Number, default: 0
  created_at  : type: Date, default: Date.now

Video.statics.register = (attributes) ->
  promise = new Hope.Promise()
  @create attributes, (error, result) ->
    promise.done(error, result)
  promise

Video.statics.attributes = (id, values) ->
  promise = new Hope.Promise()
  @findOne(_id: id).exec (error, video) =>
    return promise.done true unless video
    video.update values, (error, value) ->
      promise.done error, value
  promise

Video.statics.search = (query={}, limit=0, page=1, sort= created_at: "desc") ->
  promise = new Hope.Promise()
  range =  if page > 1 then limit * (page - 1) else 0
  @find(query).skip(range).limit(limit).sort(sort).exec (error, value) ->
    if limit is 1
      error = code: 402, message: "Video not found." if value.length is 0
      value = value[0] if value.length isnt 0
    promise.done error, value
  promise

Video.statics.techTags = (data) ->
  keys =
    JAVASCRIPT  : ["javascript", "js", "jquery", "ecmascript", "es6"]
    PYTHON      : ["python", "py", "django"]
    RUBY        : ["ruby", "rb", "sinatra", "rails"]
    CSS         : ["css", "css2", "css3", "stylesheet"]
    PHP         : ["php", "symfony"]
    JAVA        : [" java "]
    DART        : ["dart"]
    TYPESCRIPT  : ["typescript"]
    COFFEESCRIPT: ["coffeescript"]
    CLOJURE     : ["clojure"]
    SCALA       : ["scala"]
    HASKELL     : ["haskell"]
    LAMBDA      : ["lambda"]
    ERLANG      : ["erlang"]
    SQL         : [" sql "]

    NODEJS      : ["node", "node.js", "nodejs", "iojs", "io js"]
    REDIS       : ["redis"]
    MONGODB     : ["mongodb", "mongo", "mongo db"]
    APPENGINE   : ["gae", "app engine", "appengine"]
    HADOOP      : ["hadoop"]
    RABBITMQ    : ["rabbitmq"]
    POSTGRESQL  : ["postgresql"]
    MYSQL       : ["mysql"]
    APACHE      : ["apache"]
    ANGULARJS   : ["angular"]
    DJANGO      : ["django"]

    ANDROID     : ["android"]
    IOS         : ["ios", "iphone", "ipad", "ipod", "apple"]

    EVENT       : ["conference", "livestreaming", "event", "talks", "developer day", "dev day"]
    DESIGN      : ["design"]
    UX          : ["ux", "user experience"]
    PATTERNS    : ["patterns"]
    TESTING     : ["test", "tdd", "bdd", "ddd"]
    NOSQL       : ["nosql"]
    DB          : ["database", "indexing"]
    BIGDATA     : ["bigdata", "big data", "elastic search", "elasticsearch"]
    TOOLS       : ["vim", "sublime"]
    FRAMEWORK   : ["framework", "ember", "angular", "backbone", "sails", "react", "polymer", "flux"]
    HTML5       : ["html5"]
    SCRAPING    : ["scraping"]
    CLOUD       : ["cloud"]
    MOBILE      : ["mobile", "smartphone"]
    PERFOMANCE  : ["perfomance"]
    PAYMENTS    : ["bitcoin", "stripe", "paypal"]
    WEB         : ["web"]
    GIT         : ["github", "bitbucket", " git "]
    OPENSOURCE  : ["open source"]
    STARTUP     : ["startup", "founder"]
    ANALYTICS   : ["analytics"]
    PUPPET      : ["puppet"]
    SECURITY    : ["security", "hacking"]
    GAMING      : ["game", "gaming"]

  tags = []
  for key, values of keys
    for value in values
      if data.title.toLowerCase().indexOf(value) > -1
        tags.push key.toLowerCase()
        break
      if data.description.toLowerCase().indexOf(value) > -1
        tags.push key.toLowerCase()
        break
      if data.author.name.toLowerCase().indexOf(value) > -1
        tags.push key.toLowerCase()
        break
  tags

Video.methods.parse = ->
  id            : @_id.toString()
  title         : @title
  description   : @description
  image         : @image
  embed         : @embed
  duration      : @duration
  tags          : @tags
  type          : @type
  language      : @language
  author        : @author
  level         : @level
  views         : @views
  created_at    : @created_at

module.exports = db.model "Video", Video
