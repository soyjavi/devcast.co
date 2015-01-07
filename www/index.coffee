"use strict"

Session = require "../common/session"

module.exports = (zen) ->

  zen.get "/", (request, response) ->
    Session(request, response, redirect = true).then (error, session) ->
      binding =
        page    : "index"
        session : session
      response.page "base", binding, ["partial.index"]
