Ftp = require './ftpclass'

module.exports =
    activate: ->
        @ftp = new Ftp()

    deactivate: ->
        @ftp?.destroy()
        @ftp = null
