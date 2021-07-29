import { browser, dev, mode } from "$app/env"

import debug from "./Console.coffee"

import Sugar from "sugar-and-spice"
Sugar.extend()

`const appPrefix = import.meta.env.VITE_ENV_PREFIX`
import PgForwardMigration from "pg-forward-migrations"
import Database from "../Database/Postgresql.coffee"



Server =

  initialized: false
  environment: process.env["#{appPrefix}_ENVIRONMENT"]
  database: undefined

  database_configuration: 
    user: process.env["#{appPrefix}_DATABASE_USER"]
    host: process.env["#{appPrefix}_DATABASE_HOST"]
    database: process.env["#{appPrefix}_DATABASE_NAME"]
    password: process.env["#{appPrefix}_DATABASE_PASSWORD"]
    port: process.env["#{appPrefix}_DATABASE_PORT"]
    max: 20
    idleTimeoutMillis: 30000
    connectionTimeoutMillis: 2000
  
  migration_configuration: 
    migrationPath: "./db/migrations"
    database: @database
  


  
  initialize: ()->
    debug.error "Server Initialization"
    @database = new Database(Server.database_configuration)    
    
    debug.error "Initialized database"

    unless @environment == "development"  || @environment.length == 0 # prod only
      try
        debug.announce "Run Outstanding Migrations"
        outstandingMigrations = new PgForwardMigration(@migration_configuration)
        outstandingMigrations.migrate()
      catch e
        debug.announce "Migration Error"
        debug.log e
        debug.footer()


    @initialized = true

  get_database: ()->
    unless @database?
      debug.error "Reinitialized database"
      @database = new Database(@database_configuration)
    return @database

  locals: ()->
    return 
      env: @environment
      db: @get_database()


  prepare: (request)->
    if request.path.startsWith "/app/api"
      #console.log database.pool
      request.locals = Server.locals()
    return request




  seed: ()->


  migrate: ()->






export default Server