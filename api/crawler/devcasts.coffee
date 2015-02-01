###
Base class for KulturKlik
@author Javier Jimenez Villar <javi@tapquo.com> || @soyjavi
###
"use strict"

$       = require "cheerio"
Crawler = require "../../common/crawler"
Model   = require "../../common/models/video"

class DevCasts extends Crawler

  results : []

  domain  : "http://www.devcasts.io/"

  start: =>
    super [@domain], @page

  finish: ->
    super
    console.log "✓ New videos: #{@results.length}"
    @results = []

  page: (error, response, body) ->
    body.find(".content li a").each (index, a) =>
      href = $(a).attr "href"
      @queue "#{@domain}#{href}", @group

  group: (error, response, body) ->
    body.find("a.screen_link").each (index, a) =>
      href = $(a).attr "href"
      @queue "#{@domain}#{href}", @item

  item: (error, response, body) ->
    post = body.find("#post_show")

    data =
      url         : post.find("[itemprop=URL]").attr "content"
      title       : body.find("title").text()
      description : post.find("[itemprop=description]").attr "content"
      image       : post.find("[itemprop=thumbnailUrl]").attr "content"
      embed       : post.find("[itemprop=embedURL]").attr "content"
      duration    : _duration post
      # tags        : _tags post
      type        : DEVELOPMENT = 0
      language    : ENGLISH = "EN"
      author      :
        name      : post.find(".author_name > a").text()
        bio       : post.find(".author_about_me").text()
        avatar    : post.find("#post_author_about > div > div > img").attr "src"
        twitter   : _twitter post
      # created_at  :
    data.reference = _reference data
    data.tags = Model.techTags data

    Model.register(data).then (error, value) =>
      if value then @results.push id: value._id, title: value.title


exports = module.exports = DevCasts

_reference = (data) ->
  value = data.url.split("?v=").pop() if data.url.indexOf("youtube") > 0
  value

_duration = (el) ->
  time = el.find("[itemprop=duration]").attr("content").replace("PT", "")

  total = 0
  hours = time.split("H")
  if hours.length > 1
    total = (parseInt(hours[0]) * 60) + parseInt(hours[1].split("M")[0])
  else
    total = time.split("M")[0]

  parseInt total

_tags = (el) ->
  ($(tag).text() for tag in el.find("a.screencast_tag > .label"))

_twitter = (el) ->
  value = el.find(".fa-twitter-square")?.parent?("a").attr?("href").split("/").pop()
  value
