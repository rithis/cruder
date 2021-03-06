events = require "events"


module.exports = class Controller extends events.EventEmitter
  constructor: (@Model, @url, @params) ->
    @_disabled = false

  disable: ->
    @_disabled = true
    @

  enable: ->
    @_disabled = false
    @

  disabled: ->
    @_disabled
    @

  enabled: ->
    not @_disabled

  register: (app) ->
    app[@method] @url, (req, res) =>
      @_controller req, res
    @

  _params: (req) ->
    filter = {}

    for key, value of req.params
      if @params[key]
        filter[@params[key]] = value

    filter

  _controller: (req, res) ->
    return res.send 405 if @_disabled
    @controller req, res

  _sendFiltered: (req, res, code, data) ->
    @_send req, res, code, data, true

  _send: (req, res, code, data, filter = false) ->
    @emit "beforeSending", req, res, data

    if typeof @beforeSending is "function"
      if filter
        data = @beforeSending req, res, data
      else
        @beforeSending req, res, data

    res.send code, data

    @emit "afterSending", req, res, data

    if typeof @afterSending is "function"
      @afterSending req, res, data
