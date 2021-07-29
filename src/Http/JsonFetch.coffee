import { goto } from '$app/navigation'

class JsonFetch

  base_url: "/app/api/"

  type: "json"

  ###
      @xhr.defaults.headers =
      'Cache-Control': 'no-cache'
      'Pragma': 'no-cache'
      'Expires': '0' 
  ###

  constructor: ()->


  get: (url, options)->
    options = 
      method: "GET"
      headers:
        "Content-Type": "application/json"
    response = await @fetch(url, options)
    return response

  post: (url, model) ->
    options = 
      method: "POST"
      # cache: "no-cache"        
      headers: 
        "Content-Type": "application/json"
      body: JSON.stringify(model)
    response = await @fetch url, options
    return response



  put: (url, model)->
    options = 
      method: "PUT"
      # cache: "no-cache"
      headers: 
        "Content-Type": "application/json"
      body: JSON.stringify(model)
    response = await @fetch url, options
    return response

  patch: (url, model)->
    patchOptions = 
      method: "PATCH"
      # cache: "no-cache"
      headers: 
        "Content-Type": "application/json"
      body: JSON.stringify(model)   
    response = await @fetch url, patchOptions 
    return response

  delete: (url)->
    deleteOptions = 
      method: "DELETE"
      headers: 
        "Content-Type": "application/json"
    response = await @fetch url, deleteOptions 
    return response

  fetch: (url, options)->
    console.error "[#{options.method}] #{url}"
    console.log options
    console.log url
    response = await fetch url, options 
    json = await response.json()
    console.error "fetch #{url}"
    console.log json
    # TODO: This has to be handled better
    if json.authenticated?
      if json.authenticated
        return json
      else
        # TODO: handle unauthenticated
        # goto "/login"
        return json
    else
      return json


        
      


export default JsonFetch