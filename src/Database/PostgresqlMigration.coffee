Sugar = require "sugar"
Sugar.extend()
import path from "path"
import hasha from "hasha"
import fs from "fs-extra"
import chalk from "chalk"
import klawSync from 'klaw-sync'
import pg from "pg"

class PgForwardMigration

  client: {}
  config: {}

  executed_migrations: [] # from pg_migrations
  queued_migrations: [] # populated with file_migrations
  completed_migrations: [] # populated with freshly executed migrations

  constructor: (config)->
    
    @client = new pg.Pool(config.database)
    @config = config

  # build the queue
  enqueue: ()->
    that = @


    # populate file_migrations array

    

    migrationFilter = (item)->
      item.path.endsWith(".sql") && item.path.includes("__")

    scannedFiles = klawSync("#{@config.migrationPath}" , {nodir: true, filter: migrationFilter}).sortBy (item)->
      return item.path

    migrationPaths = scannedFiles.map (item)->
      item.path

    migrationPaths.forEach (item)->
      filename = path.basename(item,".sql")
      filename_chunks = filename.split("__")
      version_tag = filename.split("__")[0]
      description = filename.from(version_tag.length + 2).spacify()

      that.queued_migrations.push
        version_tag: version_tag
        description: description
        script_path: item
        script_filename: path.basename(item)
        script_md5: hasha.fromFileSync(item, {algorithm: 'md5'})
        executed_by: that.config.database.user
        executed_at: null
        execution_duration: null
        success: 0

    # populate executed_migrations array from db

    console.log chalk.gray("Checking for completed migrations")


    
    sql = "select * from pg_migrations order by id asc"
    try
      result = await @client.query(sql)
    
      that.executed_migrations = result.rows
      
      console.log chalk.gray("Cleaning up executed migrations from queue...")
      that.executed_migrations.forEach (executed_migration)->
        that.queued_migrations.remove (file_migration)->
          if (file_migration.script_filename == executed_migration.script_filename)
            console.log chalk.gray("#{executed_migration.script_filename} already executed. Skipping")
          return (file_migration.script_filename == executed_migration.script_filename)

      that.queued_migrations.forEach (queued_migration)->
        console.log chalk.white("#{queued_migration.script_filename} is new and will be queued.")



      console.log "#{that.queued_migrations.length} migrations outstanding."


      that.nextInQueue()
    catch err
      console.log chalk.red("Error while retrieving executed migrations")
      console.log err
      that.finish()




  nextInQueue: (rootScope)->

    that = @

    logSql = "insert into pg_migrations (version_tag,description,script_path,script_filename,script_md5, executed_by,executed_at,execution_duration, success) values ($1,$2,$3,$4,$5,$6,$7,$8,$9) "

    if @queued_migrations.length > 0

      currentMigration = @queued_migrations.shift()

      migrationSql = fs.readFileSync(currentMigration.script_path).toString()

      currentMigration.executed_at = Date.create()
      try 
        result = await @client.query(migrationSql)
        currentMigration.execution_duration = currentMigration.executed_at.millisecondsAgo()
        currentMigration.success = 1
        that.completed_migrations.push currentMigration
        console.info chalk.green("Migrating: #{currentMigration.script_filename}")


        # log migration

        
        try
          result = await @client.query logSql, Object.values(currentMigration)
          that.nextInQueue()
        catch innerErr
          console.error chalk.red("Error trying to record migration into pg_migrations")
          console.error innerErr
          that.finish()


      catch err
        console.error chalk.red("Error trying to migrate #{currentMigration.script_filename}")
        console.log "-".repeat(120)
        console.error "Trace:"
        console.error err
        console.log "-".repeat(120)
        console.log ""
        that.finish()


    else
      that.finish()




  # Check the migrations table, create if it doesn't exist, then enqueue migrations
  start: ()->
    that = @
    
    # 
    console.log chalk.gray("Check Migrations Table")
    migrationSql ="""
      CREATE TABLE IF NOT EXISTS pg_migrations
      (
        id bigserial,
        version_tag character varying(10) not null,
        description character varying(256) not null,
        script_path character varying(1024) not null,
        script_filename character varying(256) not null,
        script_md5 varchar(256) not null,
        executed_by character varying(100) not null,
        executed_at timestamp without time zone NOT NULL DEFAULT now(),
        execution_duration integer not null,
        success smallint not null,
        CONSTRAINT pg_migrations_pkey PRIMARY KEY (id)
      );

    """
    console.log chalk.gray("Ensuring that pg_migrations table exists.")
    try
      result = await result = await @client.query(migrationSql)
      that.enqueue()
    catch err
      console.log chalk.red("Error trying to check the pg_migrations table exists")
      console.log err
      that.finish()

  migrate: ()->
    console.log chalk.white("PG Forward Migrations")
    @start()

  finish: ()->
    @client.end()
    console.log chalk.white("Task finished. #{@completed_migrations.length} migrations were executed.")



module.exports = PgForwardMigration
