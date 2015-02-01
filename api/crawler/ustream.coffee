"use strict"

$       = require "cheerio"
Crawler = require "../../common/crawler"
Model   = require "../../common/models/video"

class UStream extends Crawler


  results : []

  domain  : "http://www.ustream.tv"

  channels: [
    "craft",
    "craftconf",
    "craftconf1"]

  start: =>
    urls = ("#{@domain}/channel/#{channel}" for channel in @channels)

    super urls, @page

  finish: ->
    super
    console.log "✓ New videos: #{@results.length}"
    @results = []

  page: (error, response, body) ->
    id = body.find("[name='ustream:channel_id']").attr "content"
    if id
      url = "http://www.ustream.tv/ajax/socialstream/videos/#{id}/1.json"
      @queue url, @page
    else
      obj = JSON.parse(response.body)
      body = $(obj.data)
      body.each (index, li) =>
        href = $(li).children("a").attr "href"
        @queue "#{@domain}#{href}", @item if href

      if obj.nextUrl then @queue "#{@domain}#{obj.nextUrl}", @page

  item: (error, response, body) ->
    post = body.find "#MainContent"

    id = body.find("[property='og:url']").attr("content").split("/").pop()
    data =
      reference   : id
      url         : body.find("[property='og:url']").attr "content"
      title       : body.find("[property='og:title']").attr "content"
      description : body.find("[property='og:description']").attr "content"
      image       : body.find("[property='og:image']").attr "content"
      embed       : body.find("[name='twitter:player']").attr "content"
      # duration    :
      # tags        :
      type        : DEVELOPMENT = 0
      language    : ENGLISH = "EN"
      author      :
        name      : post.find(".title a.state").text().trim()
        # bio       :
        avatar    : post.find(".title.has-img > img").attr "src"
        # twitter   :
      created_at  : new Date (post.find(".date > span").attr("data-timestamp") * 1000)

    data.tags = Model.techTags data
    Model.register(data).then (error, value) =>
      if value then @results.push id: value._id, title: value.title


exports = module.exports = UStream

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
