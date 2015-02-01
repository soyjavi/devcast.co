###
Base class for KulturKlik
@author Javier Jimenez Villar <javi@tapquo.com> || @soyjavi
###
"use strict"

Yoi   = require "yoi"
$     = Yoi.$
Model = require "../../models/video"
C     = global.config.C

class WatchMeCode extends Yoi.Crawler

  results : []

  domain  : "http://sub.watchmecode.net/categories/free/"

  start: =>
    super [@domain], @page

  finish: ->
    super
    console.log "✓ New videos: #{@results.length}"
    @results = []

  page: (error, response, body) ->
    # Pagination
    href = body.find(".pagination .pagination-next a").attr "href"
    # @queue href, @page if href?

    # Items
    href = body.find(".entry-title > a").attr "href"
    @queue href, @item

    # body.find(".entry-title > a").each (index, a) =>
    #   href = $(a).attr "href"
    #   @queue "#{@domain}#{href}", @item

    @stop()

  item: (error, response, body) ->
    post = body.find ".post"

    console.log post.find("iframe").length

    data =
      # reference   : response.request.href.replace("#{@domain}/", "")
      # url         : response.request.href
      title       : post.find(".entry-header .entry-title").text()
      description : post.find(".entry-content p").first().text()
    #   image       : @domain + post.find("video").attr "poster"
    #   embed       : post.find("video > source").attr "src"
    #   # duration    :
    #   # tags        :
    #   type        : C.VIDEO.TYPE.DEVELOPMENT
    #   language    : C.LANGUAGE.ENGLISH
    #   author      :
    #     name      : "Hendrik Swanepoel"
    #     bio       : "Hendrik lives in Cape Town, South Africa and doesn't surf. He likes coding, designing, teaching and learning. His two schnauzers feature in his screencasts and he likes taking them on mountain hikes with his little daughter and wife."
    #     avatar    : "http://tagtree.tv/images/authors/hendrik.jpg"
    #     twitter   : "tagtreetv"
    #   # created_at  :

    console.log data
    # Model.register(data).then (error, value) =>
    #   if value then @results.push id: value._id, title: value.title


exports = module.exports = WatchMeCode

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
