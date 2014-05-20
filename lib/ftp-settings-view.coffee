{View, $, $$$} = require 'atom'
File = require("pathwatcher").File
fs = require 'fs'

module.exports =
class FtpSettingsView extends View
    ftpdetails = null
    @content: ->
        @div class: 'ftpsettings overlay from-top ', =>
            @h1 "Project FTP Settings"

            @div "Fill in the FTP details for the current project below.", class: "message"

            @div class: 'formrow editor-container native-key-bindings', =>
                @input outlet: 'inputServer', id:"server", type :'text', name: 'server', placeholder: 'server', class: 'editor editor-colors mini native-key-bindings'

            @div class: 'formrow editor-container native-key-bindings', =>
                @input outlet: 'inputUsername', id:"username", type :'text', name: 'username', placeholder: 'username', class: 'editor editor-colors mini native-key-bindings'

            @div class: 'formrow editor-container native-key-bindings', =>
                @input outlet: 'inputPassword', id:"password", type :'password', name: 'password', placeholder: 'password', class: 'editor editor-colors mini native-key-bindings'

            @div class: 'formrow editor-container native-key-bindings', =>
                @input outlet: 'inputPort', id:"port", type :'text', name: 'port', placeholder: '21', class: 'editor editor-colors mini native-key-bindings'

            @div class: 'formrow editor-container native-key-bindings', =>
                @input outlet: 'inputRemotepath', id:"remotepath", type :'text', name: 'remotepath', placeholder: 'remote path', class: 'editor editor-colors mini native-key-bindings'

            @div class: 'formrow editor-container native-key-bindings', =>
                @input type: 'checkbox',  name: "uploadonsave", id:"uploadonsave"
                @label for: "uploadonsave", =>
                    @span "Upload on Save"

            @div class: 'formrow editor-container native-key-bindings', =>
                @input type: 'checkbox',  name: "uploadonchange", id:"uploadonchange"
                @label for: "uploadonchange", =>
                    @span "Upload on Change"

            @div class: 'formrow submit btn-group', =>
                @input id: 'ftpsettings_close', value: 'Cancel', class: 'btn'
                @input id: 'ftpsettings_save', value: 'Save', class: 'btn btn-primary'


    initialize: (serializeState) ->
        atom.workspaceView.append(this)

        currentProject = atom.project
        CSON = require 'season'

        settingsFile = new File(currentProject.getPath() + "/ftp.json");

        if settingsFile.exists()
            @ftpdetails = CSON.readFileSync currentProject.getPath() + "/ftp.json"

            $("input#server").val(@ftpdetails.server)
            $("input#username").val(@ftpdetails.username)
            $("input#password").val(@ftpdetails.password)
            $("input#port").val(@ftpdetails.port)
            $("input#remotepath").val(@ftpdetails.remotepath)
            if @ftpdetails.uploadonsave
                $("input#uploadonsave").attr "checked", true
            else
                $("input#uploadonsave").prop "checked", false

            if @ftpdetails.uploadonchange
                $("input#uploadonchange").attr "checked", true
            else
                $("input#uploadonchange").prop "checked", false
        else
            @ftpdetails =
                server: ''
                username: ''
                password: ''
                port: 21
                remotepath: ''
                uploadonsave: false
                uploadonchange: false
                watchedfile: []
            settingsFile.write JSON.stringify(@ftpdetails);

        $(document).on('click', '#ftpsettings_save', ( =>
            @save()
        ))

        $(document).on('click', '#ftpsettings_close', ( =>
            @destroy()
        ))


    # Returns an object that can be retrieved when package is activated
    serialize: ->

    save: ->
        currentProject = atom.project
        CSON = require 'season'

        settingsFile = new File(currentProject.getPath() + "/ftp.json");

        if settingsFile.exists()
            @ftpdetails = CSON.readFileSync currentProject.getPath() + "/ftp.json"

            @ftpdetails.server = $("input#server").val()
            @ftpdetails.username = $("input#username").val()
            @ftpdetails.password = $("input#password").val()
            @ftpdetails.port = $("input#port").val()
            @ftpdetails.remotepath = $("input#remotepath").val()
            @ftpdetails.uploadonsave = $("input#uploadonsave").is(":checked")
            @ftpdetails.uploadonchange = $("input#uploadonchange").is(":checked")


        CSON.writeFileSync currentProject.getPath() + "/ftp.json", @ftpdetails

        @detach()

    # Tear down any state and detach
    destroy: ->
        @detach()
