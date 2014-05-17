Ftp = require './ftpclass'

module.exports =
    activate: ->
        console.log "Atom FTP Activated"
        @ftp = new Ftp()

    deactivate: ->
        @ftp?.destroy()
        @ftp = null
