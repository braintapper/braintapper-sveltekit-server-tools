###

# Model


Pooled query execution for PG

## Dependencies

* pg
* sugar (mainly for array and object ops)

###

import Sugar from 'sugar-and-spice'
import Console from "../Utility/Console.coffee"


Sugar.extend()


import pg from "pg"
import sqt from "sql-template-strings"





class Database

  debug: false

  pool: {}
  config: {}
  environment: {}
  sqt: undefined
  date_format: "%Y-%m-%d %H:%M:%S"
  timestamps: true # add created_at, updated_at

  default_table: "tablename"

  # utility functions

  sanitize_for_sql: (string)->
    return string.replaceAll("'","''")

  sanitize_for_like: (string)->
    # \%_
    string = string.replaceAll("\\","\\\\")
    string = string.replaceAll("%","\\%")
    string = string.replaceAll("_","\\_")
    return string

  coalesce: (val, nullReplacement, stringify)->
    stringify = stringify || false
    unless val?
      val = nullReplacement
    if stringify
      return "'#{val}'"
    else
      return val
      
  format_money: (num)->
    if num < 0
      return "-$#{Math.abs(num.format(2))}"
    else
      return "$#{num.format(2)}"

  # postgresql type oids
  types: 
    date: 1082
    numeric: 1700
    time_without_time_zone: 1083
    timestamp_without_timezone: 1114
    timestamp_with_time_zone: 1184
    interval: 1186
    time_with_time_zone: 1266

  constructor: (options)->
    try
      @config = options
      @sqt = sqt

      pg.defaults.parseInt8 = true

      parseDate = (date)->
        return Date.create(date, {fromUTC: true})

      parseDateTz = (date)->
        return Date.create(date, {fromUTC: false})

      [@types.time_without_timezone,@timestamp_without_timezone].forEach (type)->
        pg.types.setTypeParser(type, parseDate)
      [@types.time_with_time_zone, @types.timestamp_with_time_zone].forEach (type)->
        pg.types.setTypeParser(type, parseDateTz)

      pg.types.setTypeParser @types.date, (val)->
        return val

      pg.types.setTypeParser @types.numeric, 'text', parseFloat

      # create the pool
      
      @pool = new pg.Pool options


    catch e
      console.log e


  execute: (sql)->
    try
      result = await @pool.query sql
      return result
    catch e
      console.log "PG Database ERROR"
      console.log e

  # execute sql with a pool client - use for transactions or multiple queries
  client_execute: (sql)->
    try
      # console.log pool
      client = await @pool.connect()
      #console.log sql
      result = await client.query sql
      released = await client.release()
      
      #console.log "released"
      return result
    catch e
      
      console.log "PG Database ERROR"
      console.log e



export default Database