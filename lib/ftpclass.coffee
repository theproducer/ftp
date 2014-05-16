File = require("pathwatcher").File
fs = require 'fs'
jsftp = require 'jsftp'
{Subscriber} = require 'emissary'

FtpSettingsView = require "./ftp-settings-view"

module.exports =
class Ftp
    Subscriber.includeInto(this)

    constructor: ->
        @subscribe atom.workspace.eachEditor (editor) =>
            @handleEvents(editor)

        @subscribe atom.workspaceView.command 'ftp:settings', =>
            @settings()

    destroy: ->
        @unsubscribe()

    settings: ->
        settingsView = new FtpSettingsView();

    handleEvents: (editor) ->
        buffer = editor.getBuffer()

        @subscribe buffer, 'saved', =>
            console.log "file saved!  Upload..."

        @subscribe buffer, 'destroyed', =>
            @unsubscribe(buffer)
