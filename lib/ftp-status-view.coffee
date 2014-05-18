{View, $, $$$} = require 'atom'

module.exports =
class FtpStatusView extends View
    @content: ->
        @div class: 'ftpstatus inline-block', =>
            @div outlet: 'container', class: 'ftpstatus-container', =>
                @span outlet: 'statusreport', class: 'ftpstatus-status', tabindex: '-1', ""

    initialize: ->


    addToStatusBar: (message) ->
        this.detach()
        @statusreport.text message
        atom.workspaceView.statusBar.prependRight(this)

    updateMessage: (message) ->
        @statusreport.text message

    removeFromMessageBar: ->
        $(".ftpstatus-status").delay(1500).fadeOut 300, ( =>
            this.detach()
        )
