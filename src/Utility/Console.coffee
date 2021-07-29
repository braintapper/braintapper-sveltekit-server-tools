import chalk from "chalk"
import figlet from "figlet"
import { browser, dev, mode } from "$app/env"
import Sugar from "sugar-and-spice"
Sugar.extend()


Console = {

  out: (msg)->
    env = if dev then "DEV" else "PRD"
    timestamp = chalk.gray(Date.create().format("%Y-%m-%d %H:%M:%S"))
    if Object.isObject(msg)
      console.log "[#{timestamp}] [#{env}] Object"
      if browser
        console.log msg
      else
        try
          console.log JSON.stringify(msg,null,2)
        catch e
          console.log msg
    else
      console.log "[#{timestamp}] [#{env}] #{msg}"


  test: ()->
    console.log "test"

  log: (msg)->
    @out msg

  request: (method, path, client)->
    @out "#{chalk.yellow(method)} #{path} [#{client}]"

  error: (msg)->
    @out chalk.red msg

  todo: (msg)->
    @out chalk.bgRed.white msg

  announce: (msg)->
    console.log ""
    console.log "=".repeat(100)
    @out "Announcement"

    figText = figlet.textSync(msg)

    console.log chalk.blue(figText)

    console.log "=".repeat(100)
    console.log ""
    
  footer: ()->
    console.log "=".repeat(100)

}



export default Console