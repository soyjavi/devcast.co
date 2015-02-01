"use strict"

$       = require "cheerio"
Crawler = require "../../common/crawler"
Model   = require "../../common/models/video"

class TagTree extends Crawler


  results : []

  domain  : "http://tagtree.tv"

  start: =>
    super [@domain], @page

  finish: ->
    super
    console.log "✓ New videos: #{@results.length}"
    @results = []

  page: (error, response, body) ->
    body.find(".screencast > .meta > a").each (index, a) =>
      href = $(a).attr "href"
      @queue "#{@domain}#{href}", @item

  item: (error, response, body) ->
    post = body.find "#screen-cast-detail-content"

    data =
      reference   : response.request.href.replace("#{@domain}/", "")
      url         : response.request.href
      title       : body.find(".detail-heading").text()
      description : post.children("p").first().text()
      image       : @domain + post.find("video").attr "poster"
      embed       : post.find("video > source").attr "src"
      # duration    :
      # tags        :
      type        : DEVELOPMENT = 0
      language    : ENGLISH = "EN"
      author      :
        name      : "Hendrik Swanepoel"
        bio       : "Hendrik lives in Cape Town, South Africa and doesn't surf. He likes coding, designing, teaching and learning. His two schnauzers feature in his screencasts and he likes taking them on mountain hikes with his little daughter and wife."
        avatar    : "http://tagtree.tv/images/authors/hendrik.jpg"
        twitter   : "tagtreetv"
      # created_at  :
    data.tags = Model.techTags data
    Model.register(data).then (error, value) =>
      if value then @results.push id: value._id, title: value.title


exports = module.exports = TagTree

_reference = (data) ->
  value = data.url.split("?v=").pop() if data.url.indexOf("youtube") > 0
  value

_duration = (el) ->
  time = el.find("[itemprop=duration]").attr("content").replace("PT", "")

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
