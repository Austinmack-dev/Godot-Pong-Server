extends Node2D

#variables
var player_info = {}
var num_players_ready = 0
var MAX_PLAYERS = 2
const GameWorld = preload("res://Scenes/GameWorld-Server.tscn")
#change this to a valid number
const port_num = 4300


var timer
var game
var playAgainCount = 0
var backToLobbycount = 0
var quitGameCount = 0
var num_clients = 0
var client_id_at_three = 0
var sent_testing = false




master func _end_game_button_press(name, id):
	if(name == "PlayAgain"):
		playAgainCount += 1
	if(name == "BackToLobby"):
		backToLobbycount += 1
#	if(name == "Quit"):
#		quitGameCount += 1
	
#	if(quitGameCount < MAX_PLAYERS):
#		rpc("_send_client_info",player_info)
	
	if(backToLobbycount == MAX_PLAYERS):
		#someone wants to go back to lobby, 
		#therefore take everyone whose still connected back to lobby screen
		#client handles if someone left the game, for printing purposes
		num_players_ready = 0
		for i in player_info:
			player_info[i].ready = false
		rpc("_reset_lobby",player_info,id)
	
	if(playAgainCount == MAX_PLAYERS):
		#both players want to play again
		var ball_pos_moveDir = game.reset_ball_position_and_moveDir(true)
		var keys = player_info.keys()
		
		
		#rpc("_send_client_start_game",player_info,globalPlayerPosNames,ball_pos_moveDir)
		#playerPosNames.clear()
		var game = get_node("/root/GameWorld")
		game.restart_game()
	if(playAgainCount == 1 and backToLobbycount == 1):
		for i in player_info:
			player_info[i].ready = false
		#only one player wants to play again, so send everyone back to lobby
		rpc("_reset_lobby",player_info,id)
		num_players_ready = 0
		#rpc("_set_client_to_not_ready")
	
	print("num_players_ready in end_game_button_press " + str(num_players_ready))

func set_players_to_not_ready():
	pass

func _ready():
	var server = NetworkedMultiplayerENet.new()
	#TODO: use a valid port when actually playing the game
	server.create_server(port_num, 3)
	get_tree().multiplayer.set_network_peer(server)
	get_tree().multiplayer.connect("network_peer_connected", self, "_network_peer_connected");
	get_tree().multiplayer.connect("network_peer_disconnected", self, "_network_peer_disconnected");
	

func _network_peer_connected(id):
	num_clients += 1
	#For future data testing of the server
	if(num_clients == 3):
		rpc_id(id,"_testing_client")
	
	
func _network_peer_disconnected(id):
#	get_node("/root/Node2D").show()
#	if(has_node("/root/GameWorld")):
#		get_node("/root/GameWorld").hide()
	print("name of player who disconnected: " + player_info[id].name)
	var connectionStatus = get_node("/root/Node2D/connectionStatus")
	var numClientsLabel = get_node("/root/Node2D/numClientsLabel")
	connectionStatus.text = connectionStatus.text + "\n client " + str(id) + " disconnected"
	player_info.erase(id)
	numClientsLabel.text = "Number of Clients connected: " + str(player_info.size())
	#make it so that the number of players is one less, since someone disconnected
	if(num_players_ready > 0):
		num_players_ready -= 1
	
	if(player_info.size() == 0):
		player_info.clear()
	
	#if there are still players left, set all the players left back to false, and resend out the _send_client_ready rpc
	#which will update the lobby view for the clients
	if(player_info.size() > 0):
		for i in player_info:
			player_info[i].ready = false
			print("name sent back : " + player_info[i].name + "\n")
		rpc("_reset_lobby",player_info, id)

	#TODO: remove the client's player who just recently disconnected, so that the server no longer sends RPCs from there
	
func _print_player_info():
	for pInfo in player_info:
		print("player_info: " + str(player_info))

master func _send_server_info(info, id):
	var sender_id = get_tree().multiplayer.get_rpc_sender_id()

	
	#add to the player info
	if(not player_info.has(id) and player_info.size() < MAX_PLAYERS):
		player_info[id] = info
	#modify the player_info
	elif(player_info.has(id) and player_info.size() == MAX_PLAYERS):
		player_info[id] = info
	
	
	
	
	_print_player_info()
	
	if(player_info.has(id)):
		print("inside if statement and my id is : " + str(id) + " name: " + player_info[id].name)
		var numClientsLabel = get_node("/root/Node2D/numClientsLabel")
		numClientsLabel.text = "SERVER"
		var connectionStatus = get_node("/root/Node2D/connectionStatus")
		connectionStatus.text = connectionStatus.text + "\nclient with id: " + str(id) + " name: " + player_info[id].name + " connected"
	
		
		if(player_info[id].ready == false):
			rpc("_setup_lobby", player_info, MAX_PLAYERS)
		else:
			num_players_ready += 1
			rpc("_reset_lobby",player_info,id)
		
		
		if(num_players_ready == MAX_PLAYERS):
			
			if(has_node("/root/GameWorld")):
				game.get_node("GameStartLabel").hide()
				game.show()
				game.restart_game()
				get_node("/root/Node2D").hide()
			else:
				#mirror the game on the server
				var keys = player_info.keys()
				game = GameWorld.instance()
				get_tree().get_root().add_child(game)
				game.get_node("GameStartLabel").hide()
				get_node("/root/Node2D/serverLabel").text = get_node("/root/Node2D/serverLabel").text + " num players ready: " + str(num_players_ready)
				#create the game world objects, ball, players, etc.
				
				game.start_game(sender_id)




