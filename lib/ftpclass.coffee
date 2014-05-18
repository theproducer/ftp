File = require("pathwatcher").File
Directory = require("pathwatcher").Directory
Chokidar = require 'chokidar'
fs = require 'fs'
jsftp = require 'jsftp'
{Subscriber} = require 'emissary'

FtpSettingsView = require "./ftp-settings-view"
FtpStatusView = require "./ftp-status-view"

module.exports =
class Ftp
    Subscriber.includeInto(this)
    watcher = null

    constructor: ->
        @subscribe atom.workspace.eachEditor (editor) =>
            @handleEvents(editor)

        @subscribe atom.workspaceView.command 'ftp:settings', =>
            @settings()

        @subscribe atom.workspaceView.command 'ftp:uploadfile', =>
            @contextMenuUploadFile()

        @subscribe atom.workspaceView.command 'ftp:uploaddirectory', =>
            @contextMenuUploadDirectory()

        @subscribe atom.workspaceView.command 'ftp:watchfile', =>
            @markfileaswatched()


        @initdirectorywatching()



    destroy: ->
        @unsubscribe()
        watcher.close()
        watcher = null

    settings: ->
        settingsView = new FtpSettingsView();

    initdirectorywatching: ->
        if watcher
            watcher.close()

        watcher = null

        filepath = atom.workspaceView.find('.tree-view .selected')?.view()?.getPath?()
        currentProject = atom.project
        CSON = require 'season'

        settingsFile = new File(currentProject.getPath() + "/ftp.json")
        if settingsFile.exists()
            ftpdetails = CSON.readFileSync currentProject.getPath() + "/ftp.json"

            watcher = Chokidar.watch ftpdetails.watchedfiles[0], {ignored: /[\/\\]\./, persistent: true}

            i = 1
            while i < ftpdetails.watchedfiles.length
                watcher.add ftpdetails.watchedfiles[i]
                i++

            watcher.on 'change', (path) =>
                console.log "something has been changed!" + path
                @uploadFileOnChange(path)

    markfileaswatched: ->
        filepath = atom.workspaceView.find('.tree-view .selected')?.view()?.getPath?()
        currentProject = atom.project
        CSON = require 'season'

        settingsFile = new File(currentProject.getPath() + "/ftp.json")
        if settingsFile.exists()
            ftpdetails = CSON.readFileSync currentProject.getPath() + "/ftp.json"
            if ftpdetails.watchedfiles is null
                ftpdetails.watchedfiles = []

            ftpdetails.watchedfiles.push filepath

            settingsFile.write JSON.stringify(ftpdetails);


    contextMenuUploadFile: ->
        filepath = atom.workspaceView.find('.tree-view .selected')?.view()?.getPath?()
        console.log filepath
        @uploadFile(filepath)

    contextMenuUploadDirectory: ->
        directorypath = atom.workspaceView.find('.tree-view .selected')?.view()?.getPath?()
        console.log directorypath
        selectedDirectory = new Directory(directorypath)

        selectedDirectory.getEntries (err, files) =>
            i = 0
            while i < files.length
                console.log files[i].getPath()
                @uploadFile(files[i].getPath())
                i++

    uploadFileOnChange: (filepath) ->
        currentProject = atom.project
        CSON = require 'season'

        settingsFile = new File(currentProject.getPath() + "/ftp.json")
        if settingsFile.exists()
            ftpdetails = CSON.readFileSync currentProject.getPath() + "/ftp.json"

            if ftpdetails.uploadonchange
                @uploadFile(filepath)

    uploadFile: (filepath) ->
        currentProject = atom.project
        CSON = require 'season'

        settingsFile = new File(currentProject.getPath() + "/ftp.json")
        if settingsFile.exists()
            ftpdetails = CSON.readFileSync currentProject.getPath() + "/ftp.json"

            statusView = new FtpStatusView()
            statusView.addToStatusBar("Uploading file...")

            client = new jsftp(
                host: ftpdetails.server
                user: ftpdetails.username
                pass: ftpdetails.password
                port: ftpdetails.port
            )

            filetoupload = new File(filepath)
            patharray = atom.project.relativize filetoupload.getParent().path
            patharray = patharray.split "/"

            console.log filetoupload.getParent().path
            console.log patharray

            streamData = fs.createReadStream(filepath)
            streamData.pause();

            client.auth ftpdetails.username, ftpdetails.password, (err, res) ->
                if err
                    console.error err
                else
                    console.log "authentication successful"

                    i = 0;
                    pathArrayString = ftpdetails.remotepath

                    while i < patharray.length
                        pathArrayString = pathArrayString + "/" + patharray[i]
                        console.log "creating directory: " + pathArrayString
                        client.raw.mkd pathArrayString, (err, data) ->
                            client.raw.cwd pathArrayString, (err, data) ->
                                return
                            return

                        i++

                    client.getPutSocket pathArrayString + "/" + filetoupload.getBaseName(), (err, socket) ->
                        if err
                            console.error err
                            statusView.addToStatusBar("Upload Error")
                            statusView.removeFromMessageBar()
                            client.raw.quit()
                        else
                            streamData.pipe(socket)
                            streamData.resume()
                            client.raw.quit();
                            statusView.addToStatusBar("Upload Successful")
                            console.log "upload sucessful"
                            statusView.removeFromMessageBar()


    handleEvents: (editor) ->
        buffer = editor.getBuffer()

        @subscribe buffer, 'saved', =>
            currentProject = atom.project
            CSON = require 'season'

            settingsFile = new File(currentProject.getPath() + "/ftp.json")
            if settingsFile.exists()
                ftpdetails = CSON.readFileSync currentProject.getPath() + "/ftp.json"

                if ftpdetails.uploadonsave and ftpdetails.watchedfiles.indexOf(buffer.getPath()) is -1
                    console.log "file saved!  Upload..."
                    @uploadFile(buffer.getPath())

        @subscribe buffer, 'destroyed', =>
            @unsubscribe(buffer)
