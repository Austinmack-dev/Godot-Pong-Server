extends Area2D

var game
var lobby
var client_id
var scoreToSend = 1

func _ready():
	game = get_node("/root/GameWorld")
	lobby = get_node("/root/LobbyNode")
	client_id = lobby.my_id

func _on_ScoreZone_body_entered(body):
	#if the ball enters the score zone, get the client's id
	#send the score information to the server, if we are the client who scored
	if(body.get_name() == "Ball"):
		var myId = name.substr(10,name.length())
		#hide the ball
		body.hide()
		#if we are the client who scored, send this information to the server
		if(int(myId) == client_id):
			#send up the score, and reset the ball on the server side
			game.rpc_id(1,"_send_score_and_reset_ball",int(myId),scoreToSend)
		
		
