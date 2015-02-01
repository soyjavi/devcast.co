"use strict"

$       = require "cheerio"
Crawler = require "../../common/crawler"
Model   = require "../../common/models/video"

class Vimeo extends Crawler

  results : []

  domain  : "http://vimeo.com"

  users   : [
    "jsla",
    "webrebels",
    "chicagoruby",
    "iasanychapter",
    "user24077820",
    "awwwards"
  ]

  start: =>
    urls = ("#{@domain}/#{user}/videos" for user in @users)
    super urls, @page

  finish: ->
    super
    console.log "✓ New videos: #{@results.length}"
    @results = []

  page: (error, response, body) ->
    # Pagination
    page = body.find("#pagination a.selected").parent().next().children?("a").attr "href"
    @queue "#{@domain}#{page}", @page if page?

    # Elements
    body.find("#browse_content > ol > li > a").each (index, a) =>
      href = $(a).attr "href"
      @queue "#{@domain}#{href}", @item


  item: (error, response, body) ->
    meta = body.find "#cols"
    post = body.find "#clip"

    data =
      reference   : response.request.href.replace("#{@domain}/", "")
      url         : meta.find("[itemprop=playpageUrl]").attr "content"
      title       : post.find("[itemprop=name]").text()
      description : post.find("[itemprop=description]").text()
      image       : meta.find("[itemprop=image]").attr "content"
      embed       : meta.find("[itemprop=embedUrl]").attr "content"
      duration    : _duration meta
      # tags        :
      type        : DEVELOPMENT = 0
      language    : ENGLISH = "EN"
      author      :
        name      : post.find(".byline a[rel=author]").text()
      # bio       : "Hendrik lives in Cape Town, South Africa and doesn't surf. He likes coding, designing, teaching and learning. His two schnauzers feature in his screencasts and he likes taking them on mountain hikes with his little daughter and wife."
        avatar    : post.find("img.portrait").attr "src"
      # twitter   : "tagtreetv"
      created_at    : meta.find("[itemprop=dateCreated]").attr "content"
    data.tags = Model.techTags data

    Model.register(data).then (error, value) =>
      if value then @results.push id: value._id, title: value.title

exports = module.exports = Vimeo

_duration = (el) ->
  time = el.find("[itemprop=duration]").attr("content").replace("PT", "")

  hours = time.split("H")
  if hours.length > 1
    total = (parseInt(hours[0]) * 60) + parseInt(hours[1].split("M")[0])
  else
    total = time.split("M")[0]
  parseInt total
