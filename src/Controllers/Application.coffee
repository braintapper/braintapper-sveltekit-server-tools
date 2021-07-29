import BaseController from "./Base.coffee"


###

  route example:
  import Controller from..

  export get = (request)->

    controller = new Controller(req)

    return controller.get()


###

class ApplicationController extends BaseController

  session_cookie: undefined

  db: undefined

  authenticated: undefined


  after_construct: ()->
    @session_cookie = @request.getSessionCookie()
    @db = @request.locals.db
    if @session_cookie?
      if Date.create(@session_cookie.expires).isPast()
        @session_cookie = undefined # expired cookie
    else
      @debug.todo "TODO: handle _Application invalid cookie"

    @authenticated = @session_cookie?
    # TODO: force a logout

  # before controller execute
  before: ()->
    return @session_cookie?

  # after controller execute
  after: (output, authenticated)->
    #console.log ">>>>>>>>>>>>>>>>>>>>>>>> after"
    #console.log output
    if @session_cookie?
      #console.log "session cookie"
      unless output?
        output = {}
      @response.status = 200
      @response.body = 
        authenticated: authenticated || true
        data: output
      # update the expiry of the session cookie
      @session_cookie.expires = Date.create("8 hours from now").toJSON()
      @response.setCookie(@session_cookie)
      
    else
      # console.log "no session cookie"
      # @response.deleteCookie()
      @response.status = 200
      
      output = { authenticated: false, message: "Unauthorized", data: output }
      @response.body = output
      # @response.set(401, output)


    #console.log "------------------------------"
    #console.log @response
    #console.log @response.headers
    #console.log "------------------------------"
    unless @response.headers["set-cookie"]
      delete @response.headers["set-cookie"]
    return @response


  invalidate_session: (output)->
    @response.deleteCookie()
    @response.status = 401
    @response.body = output || { authenticated: false, message: "Unauthorized" }
    return @response


  format_output: (o)->
    #console.log "format_output"
    #console.log 

    return
      data: o

  sessioned: (fn)->
    if @authenticated
      return await @[fn]()
    else
      return @invalidate_session()

  sessionless: (fn)->
    return await @[fn]()

  sessionless_sync: (fn)->
    console.log "sessionless_sync"
    return @[fn]()

  ###
  example fn

  index: ()->
    if @before()?
      output = output # do some work
    else
      result = await @db.execute sql
      output = @format_output(result)
    return @after(output)
    
  ###

export default ApplicationController