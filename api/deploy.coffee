"use strict"
Hope          = require("zenserver").Hope
childProcess  = require "child_process"

module.exports = (server) ->

  ###
  @method POST
  ###
  server.post "/deploy", (request, response) ->
    deploy = false

    if global.ZEN.deploy
      if global.ZEN.environment is "development"
        deploy = __github request
      else
        deploy = true

    if deploy
      processes = (__asyncProcess task for task in ZEN.deploy)
      Hope.shield(processes).then (error, result) ->
        if error then response.badRequest() else response.ok()
    else
      response.paymentRequired()


  # -- PRIVATE METHODS ---------------------------------------------------------
__asyncProcess = (command, args) -> ->
  console.log " ⇢ ".yellow, "[PROCESS]".grey, command
  promise = new Hope.Promise()
  childProcess.exec command, args, (error, out) -> promise.done error, out
  promise

__github = (request) ->
  deploy = false
  if /release/i.test(request.parameters.head_commit.message)
    for commit in request.parameters.commits when deploy is false
      for file in commit.modified when /package.json/i.test(file)
        deploy = true
        break
  deploy
