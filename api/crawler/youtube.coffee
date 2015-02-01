"use strict"

$       = require "cheerio"
Crawler = require "../../common/crawler"
Model   = require "../../common/models/video"

class Youtube extends Crawler

  results : []

  domain  : "http://www.youtube.com"
  query   : "http://gdata.youtube.com/feeds/api/videos?max-results=50&orderby=published&safeSearch=none&alt=json&v=2&author="

  users   : [
    "MarakanaTechTV",
    "OreillyMedia",
    "androiddevelopers",
    "GoogleDevelopers",
    "gotreehouse",
    "ClojureTV",
    "jsconfeu",
    "TwitterUniversity",
    "FacebookDevelopers",
    "jquery",
    "SenchaInc",
    "dotconferences",
    "CodeSchoolTV",
    "W3Conf",
    "Confreaks",
    "PyCon2014",
    "webdirections",
    "technologyatbox",
    "GotoConferences",
    "DataversityChannel",
    "ThePythianGroup",
    "LivePersonDev",
    "TV4STARTUPS",
    "hasgeek",
    "ErlangSolutions",
    "SpringSourceDev",
    "yrashk",
    "HackersOnBoard",
    "ChRiStIaAn008",
    "g33ktalktv",
    "barcelonarubyconf",
    "UCwoOpKfkyCQHW562hXXQAGg",
    "nodebp",
    "gostormpath",
    "UCB4TQJyhwYxZZ6m4rI9-LyQ",
    "UCCDwsD1nLhy9AvTVEzcr6rw"
  ]

  start: =>
    urls = ("#{@query}#{user}" for user in @users)
    super urls, @user

  finish: ->
    super
    console.log "✓ New videos: #{@results.length}"
    @results = []

  user: (error, response, body) ->
    api = JSON.parse response.body

    for item in api.feed.entry
      id = item.media$group.yt$videoid.$t
      data =
        reference   : id
        url         : "#{@domain}/watch?v=#{id}"
        title       : item.title.$t
        description : item.media$group.media$description.$t
        image       : _image item.media$group.media$thumbnail
        embed       : "#{@domain}/embed/#{id}?autoplay=1"
        duration    : _duration item.media$group.yt$duration
        # tags        : _tags post
        type        : DEVELOPMENT = 0
        language    : ENGLISH = "EN"
        author      :
          name      : item.author[0].name.$t
          # bio       : post.find(".author_about_me").text()
          # avatar    : post.find("#post_author_about > div > div > img").attr "src"
          # twitter   : _twitter post
        created_at    : item.published.$t
      data.tags = Model.techTags data

      # Model.register(data).then (error, value) =>
      #   if value then @results.push id: value._id, title: value.title

exports = module.exports = Youtube

_duration = (data) ->
  value = 0
  if data.seconds? then value = data.seconds / 60
  parseInt value

_image = (thumbs) ->
  value = thumbs[0].url
  for thumb in thumbs when thumb.width > 320
    value = thumb.url
    break
  value
