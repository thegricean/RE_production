/*  Copyright (c) 2012 Sven "FuzzYspo0N" Bergström, 2013 Robert XD Hawkins
    
    written by : http://underscorediscovery.com
    written for : http://buildnewgames.com/real-time-multiplayer/
    
    modified for collective behavior experiments on Amazon Mechanical Turk

    MIT Licensed.
*/
    var
        fs    = require('fs'),
        utils = require('../../sharedUtils/sharedUtils.js');

// This is the function where the server parses and acts on messages
// sent from 'clients' aka the browsers of people playing the
// game. For example, if someone clicks on the map, they send a packet
// to the server (check the client_on_click function in game.client.js)
// with the coordinates of the click, which this function reads and
// applies.
var onMessage = function(client,message) {
  //Cut the message up into sub components
  var message_parts = message.split('.');

  //The first is always the type of message
  var message_type = message_parts[0];
  
  //Extract important variables
  var gc = client.game;
  var id = gc.id.slice(0,6);
  var all = gc.get_active_players();
  var target = gc.get_player(client.userid);
  var others = gc.get_others(client.userid);  
  switch(message_type) {
    
  case 'clickedObj' :
    writeData(client, "clickedObj", message_parts);
    others[0].player.instance.send("s.feedback." + message_parts[3]);
    target.instance.send("s.feedback." + message_parts[3]);
    setTimeout(function() {
      _.map(all, function(p){
        p.player.instance.emit( 'newRoundUpdate', {user: client.userid} );
      });
      gc.newRound();
    }, 1000);
    
    break; 
  
  case 'playerTyping' :
    console.log("player is typing?", message_parts[1]);
    _.map(others, function(p) {
      p.player.instance.emit( 'playerTyping',
			      {typing: message_parts[1]});
    });
    break;
  
  case 'chatMessage' :
    if(client.game.player_count == 2 && !gc.paused) {
      writeData(client, "message", message_parts);
      // Update others
      var msg = message_parts[1].replace(/~~~/g,'.');
      _.map(all, function(p){
	p.player.instance.emit( 'chatMessage', {user: client.userid, msg: msg});});
    }
    break;

  case 'h' : // Receive message when browser focus shifts
    target.visible = message_parts[1];
    break;
  }
};

var writeData = function(client, type, message_parts) {
  console.log(message_parts);
  var gc = client.game;
  var roundNum = gc.state.roundNum + 1;
  var id = gc.id.slice(0,6);
  switch(type) {
  case "clickedObj" :
          var trialType = message_parts[1];
      var clickedObjContext = message_parts[2];
      var clickedObjName = message_parts[3];
      var clickedObjTargetStatus = message_parts[4];
      var clickedObjSpeakerLocs = message_parts[5];
      var clickedObjListenerLocs = message_parts[6];

      var alternat1Name = message_parts[7]; 
      var alternat1TargetStatus = message_parts[8];
      var alternat1SpeakerLocs = message_parts[9];
      var alternat1ListenerLocs = message_parts[10];

      var alternat2Name = message_parts[11]; 
      var alternat2TargetStatus = message_parts[12];
      var alternat2SpeakerLocs = message_parts[13];
      var alternat2ListenerLocs = message_parts[14];
      
      var line = (id + ',' + Date.now() + ',' + roundNum + ',' + trialType + ',' + clickedObjContext 
        + "," + clickedObjName + "," + clickedObjTargetStatus + "," + clickedObjSpeakerLocs 
        + "," + clickedObjListenerLocs 
        + "," + alternat1Name + "," + alternat1TargetStatus + "," + alternat1SpeakerLocs 
        + "," + alternat1ListenerLocs 
        + "," + alternat2Name + "," + alternat2TargetStatus + "," + alternat2SpeakerLocs 
        + "," + alternat2ListenerLocs + '\n');
      console.log(line);
    break;

  case "message" :
    var msg = message_parts[1].replace('~~~','.');
    var line = (id + ',' + Date.now() + ',' + roundNum + ',' + client.role + ',"' + msg + '"\n');
    console.log("message:" + line);
    break;
  }
  gc.streams[type].write(line, function (err) {if(err) throw err;});
};

// /* 
//    The following functions should not need to be modified for most purposes
// */

var startGame = function(game, player) {
  // Establish write streams
  var startTime = utils.getLongFormTime();
  var dataFileName = startTime + "_" + game.id + ".csv";
  utils.establishStream(game, "message", dataFileName,
			"gameid,time,roundNum,sender,contents\n");
  utils.establishStream(game, "clickedObj", dataFileName,
			"gameid, time, roundNum, trialType, context," +
			"nameClickedObj, targetStatusClickedObj, spLocsClickedObj, " +
			"lisLocsClickedObj, " +
			"alt1Name, alt1TargetStatus, " +
			"alt1SpLocs, alt1LisLocs, " +
			"alt2Name, alt2TargetStatus, alt2SpLocs, alt2LisLocs\n");
  game.newRound();
};

module.exports = {
  writeData : writeData,
  startGame : startGame,
  onMessage : onMessage
};
