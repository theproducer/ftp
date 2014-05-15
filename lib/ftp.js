'use strict';

var File = require('pathwatcher').File;

var jsftp = require('jsftp');
var plugin = module.exports;

var host = 'waws-prod-bay-001.ftp.azurewebsites.windows.net';
var username = 'theproducerstudio\\theproducer';
var password = 'makazaCaxa5a';
var remotepath = ".";

plugin.activate = function(){
    atom.workspaceView.command('ftp:connect', connect);
    atom.workspaceView.command('ftp:settings', settings);
}

function connect(){
    console.log("connecting");

    var client = new jsftp({
        host: host,
        user: username,
        pass: password,
        port: 21
    });

    client.auth(username, password, function(err, res){
        if(err){
            console.error(err);
        }else{
            client.ls(".", function(err, files){
                console.log(files);
            });
        }
    });
}

function settings(){
    var currentProject = atom.project;
    var settingsFile = new File(currentProject.getPath() + "/ftp.json");
    settingsFile.write("this will be the settings json for the ftp plugin!");
    //console.log(settingsFile);
}
