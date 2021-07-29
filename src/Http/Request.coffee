# compatbility with express type of request
import debug from "../Utility/Console.coffee"
import nodeCookie from 'node-cookie'

###
type Request<Locals = Record<string, any>, Body = unknown> = {
  method: string;
  host: string;
  headers: Headers;
  path: string;
  params: Record<string, string>;
  query: URLSearchParams;
  rawBody: string | Uint8Array;
  body: ParameterizedBody<Body>;
  locals: Locals; // populated by hooks handle
};
###




class Request

  
  method: undefined
  host: undefined
  headers: undefined
  path: undefined
  params: undefined
  query: undefined
  rawBody: undefined
  body: undefined
  locals: undefined

  
  headers: 
    "set-cookie": ""

  cookieName: undefined
  cookieSecret: undefined

  constructor: (req)->
    `const appPrefix = import.meta.env.VITE_ENV_PREFIX`
    

    client = "localhost"
    if req.headers["x-real-ip"]?
      client = req.headers["x-real-ip"]

    debug.request req.method, req.path, client





    @cookieName = process.env["#{appPrefix}_COOKIE_NAME"] || "session"
    @cookieSecret = process.env["#{appPrefix}_COOKIE_SECRET"] || "0123456789012345"

    that = @
    [
      "method"
      "host"
      "headers"
      "path"
      "params"
      "query"
      "rawBody"
      "body"
      "locals"    
    ].forEach (attribute)->
      if req[attribute]?
        that[attribute] = req[attribute]


    # set cookiesecret to process env

  getHeader: (key)->
    return @headers[key]

  setHeader: (key,val)->
    @headers[key] = val

  setStatus: (status)->
    @status = status


  getSessionCookie: ()->
    cookie = JSON.parse(nodeCookie.get(@, @cookieName, @cookieSecret, true))

    return cookie

  getCookie: (cookieName)->
    nodeCookie.get(@, cookieName, @cookieSecret, true)






export default Request