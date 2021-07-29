# compatbility with express type of response

import nodeCookie from 'node-cookie'
import Console from "../Utility/Console.coffee"
debug = console
class Response

  # status: (p) => ({json: (p) => {}})
  status: 200

  body: undefined

  

  cookieOptions:
    maxAge: (8 * 60 * 60) # seconds, not milliseconds
    path: "/"
    sameSite: "Strict"
    secure: true # requires https
    httpOnly: true

  headers: 
    "set-cookie": undefined

  cookieName: undefined
  cookieSecret: undefined

  constructor: (status, body)->
    `const appPrefix = import.meta.env.VITE_ENV_PREFIX`
    if status?
      @status = status
    if body?
      @body = body
    
    # Secure cookies are required for all environments except development
    @cookieOptions.secure = (process.env["#{appPrefix}_ENVIRONMENT"] != "development")

    # set cookiesecret to process env
    @cookieName = process.env["#{appPrefix}_COOKIE_NAME"] || "session"
    @cookieSecret = process.env["#{appPrefix}_COOKIE_SECRET"] || "0123456789012345"    
    # set cookiesecret to process env

  getHeader: (key)->
    return @headers[key.toLowerCase()]

  setHeader: (key,val)->
    @headers[key.toLowerCase()] = val



  setStatus: (status)->
    @status = status


  setCookie: (cookieValue)->
    #debug.log "setCookie value"
    #debug.log cookieValue
    @headers["set-cookie"] = undefined
    #console.log @cookieOptions
    nodeCookie.create @, @cookieName, JSON.stringify(cookieValue), @cookieOptions, @cookieSecret, true

  deleteCookie: ()->
    # cookie options must be same as creation
    deleteCookie = Object.clone(@cookieOptions)
    #debug.log "delete cookie"
    #debug.log @cookieOptions
    deleteCookie.maxAge = 0
    deleteCookie["expires"] =  new Date(0) 
    nodeCookie.create @, @cookieName, "",deleteCookie, @cookieSecret, true

  set: ( options )->
    # map options to attributes




export default Response