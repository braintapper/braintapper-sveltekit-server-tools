import Request from "../Http/Request.coffee"
import Response from "../Http/Response.coffee"
import Console from "../Utility/Console.coffee"

class BaseController 

  request: undefined

  debug: Console

  before_construct: ()->

  after_construct: ()->

  constructor: (req)->
    
    @before_construct()
    @request = new Request(req)
    @response = new Response()
    @after_construct() 



export default BaseController