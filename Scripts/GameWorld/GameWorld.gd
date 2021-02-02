extends Node2D

#variables
var player1Score = 0
var player2Score = 0
var winningScore = 2
var client_id_array = Array()
var timer = Timer
var ball
var ball_pos_moveDir
const Ball = preload("res://Scenes/Ball-Server.tscn")
const PlayerScene = preload("res://Scenes/Player-Server.tscn")
var keys
var globalPlayerPosNames = []
var playerList = []

func _ready():
	pass

func reset():
	timer.start(2.0)
	set_physics_process(true)
	set_ball_and_player_physics(false,false,true)
	reset_ball_position_and_moveDir(false)

func _timer_timed_out():
	timer.stop()
	set_ball_and_player_physics(true,false,true)
	rpc("_timer_timed_out_on_server")

func set_ball_and_player_physics(ballAndPlayerPhysics,selfPhysicsProcess,showBall):
	if(showBall == true):
		ball.show()
	print("ball position in set_ball_and_player_physics: " + str(ball.position))
	ball.set_physics_process(ballAndPlayerPhysics)
	#find all the players in the gameworld
	for player in playerList:
		player.set_physics_process(ballAndPlayerPhysics)
	set_physics_process(selfPhysicsProcess)

func _physics_process(delta):
	
	if(timer.time_left >= 0.0):
		rpc("_send_client_time_left", int(timer.time_left))

master func _send_score_and_reset_ball(client_id, player_score):
	
	var keys = Networking.player_info.keys()
	#if we are player1
	if(client_id == keys[0]):
		player1Score += player_score
		rpc("_player_scored", client_id, player1Score)
		continue_game()
		
	#if we are player2
	if(client_id == keys[1]):
		player2Score += player_score
		rpc("_player_scored", client_id, player2Score)
		continue_game()
		
	if(player1Score == winningScore):
		end_game(client_id)
		
	if(player2Score == winningScore):
		end_game(client_id)
	
	
func continue_game():
	reset()
	var ball_pos = Vector2(0,0)
	rpc("_reset_ball_on_client",ball_pos)

func setup_timer():
	timer = Timer.new()
	timer.connect("timeout",self, "_timer_timed_out")
	add_child(timer)
	timer.start(1.0)
	set_physics_process(true)

func reset_game_counters():
	#reset numbers
	player1Score = 0
	player2Score = 0
	Networking.playAgainCount = 0
	Networking.backToLobbycount = 0

func restart_game():
	reset_game_counters()
	ball_pos_moveDir = reset_ball_position_and_moveDir(true)
	reset_player_position()
	Networking.rpc("_send_client_start_game",Networking.player_info,globalPlayerPosNames,ball_pos_moveDir)
	setup_timer()
	print("IN RESTART GAME TREE:")
	get_tree().get_root().print_tree_pretty()
	print("globalPlayerPosNames.size()--IN SERVER-IN RESTART: " + str(globalPlayerPosNames.size()))
	print("playerList.size()--IN SERVER-IN SETUP-IN RESTART: " + str(playerList.size()))

func start_game(sender_id):
	print("sender_id: " + str(sender_id))
	if(Networking.player_info.has(sender_id)):
		setup()
		setup_timer()
		print("IN START GAME TREE:")
		get_tree().get_root().print_tree_pretty()
	
		#reset_ball_position_and_moveDir(true)
		#ball_pos_moveDir  = reset_ball_position_and_moveDir(true)
		reset_player_position()
	
		Networking.rpc("_send_client_start_game",Networking.player_info,globalPlayerPosNames,ball_pos_moveDir)
		print("after send client start game to client")
	

func reset_player_position():
	var keys = Networking.player_info.keys()
	for i in range(0,playerList.size()):
#		var player = get_node("Player" + str(keys[i]))
		playerList[i].position = globalPlayerPosNames[i].pos
		print("player position in reset_player_position--after reset: " + str(playerList[i].position))

func reset_ball_position_and_moveDir(setMoveDir):
	var array = []
	#var ball = get_node("Ball")
	ball.position = Vector2(0,0)
	if(setMoveDir == true):
		ball.move_dir_server = Vector2(-1,-1)
	array.append(ball.position)
	array.append(ball.move_dir_server)
	return array

func setup_player(index,idVal):
	var player = PlayerScene.instance()
	player.name = "Player" + str(idVal)
	player.position = Vector2(900*index, player.position.y)
	add_child(player)
	player.set_physics_process(false)
	playerList.append(player)

func setup():
	keys = Networking.player_info.keys()
	var playerPosNames = []
	#create the game world objects, ball, players, etc.
	ball = Ball.instance()
	add_child(ball)
	ball_pos_moveDir = reset_ball_position_and_moveDir(true)
	
	#set the ball physics to false when the game is started
	#is controlled by the timer
	ball.set_physics_process(false)
	for i in range(0,Networking.num_players_ready):
		var player = setup_player(i,keys[i])
		var pPos = playerList[i].position
		var pName = playerList[i].name
		var pGameName = Networking.player_info[keys[i]].name
		var playerPosName = {pos = pPos, playerName=pName, playerGameName=pGameName}
		playerPosName.pos = playerList[i].position
		playerPosName.playerName = playerList[i].name
		playerPosNames.append(playerPosName)
		if(i == 1):
			var playerSprite = playerList[i].get_node("Sprite")
			playerSprite.texture = preload("res://Shared/paddle2.png")
	#hide the lobby to show the game	
	get_node("/root/Node2D").hide()
	globalPlayerPosNames = playerPosNames
	print("globalPlayerPosNames.size()--IN SERVER-IN SETUP: " + str(globalPlayerPosNames.size()))
	print("playerList.size()--IN SERVER-IN SETUP: " + str(playerList.size()))

func end_game(client_id):
	remove_child(timer)
	set_physics_process(false)
	rpc("_end_game",Networking.player_info[client_id].name)