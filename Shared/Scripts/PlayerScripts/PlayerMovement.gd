extends KinematicBody2D

var moveY = 0
var toMove = Vector2()
var player_id
var isControlling = 0
const moveSpeed = 350
var serverMove = Position2D
var originalPos

puppet func _move_player(serverPos, id):
	var beingControlled = name.find(str(id))
	if(beingControlled != -1):
		position = serverPos

func _ready():
	var lobby = get_node("/root/LobbyNode")
	player_id = lobby.my_id
	isControlling = name.find(str(player_id))
	originalPos = position

func _physics_process(delta):
	#if the client in focus is the same as my network id
	#get the inputs from the keyboard, and move based on those inputs
	if isControlling != -1:
		
		
		#resets the moveY variable to not constantly move
		moveY = 0
		#if the user presses up or W, then move up
		if Input.is_key_pressed(KEY_UP) or Input.is_key_pressed(KEY_W):
			moveY = moveY - 1
		#if the user presses down or S, move down
		if Input.is_key_pressed(KEY_DOWN) or Input.is_key_pressed(KEY_S):
			moveY = moveY + 1
		toMove = Vector2(0,moveY)
		if(moveY != 0):
			rpc_id(1,"_send_server_movement_data",moveY,player_id,delta)
		#set the move Vector2 to move in the y direction only, since our paddles
		#are on the left and right of the game world screen
		
		#send the movement data from our controlled player to the server
		#move based on the calculated move vector
		move_and_collide(toMove.normalized()*moveSpeed*delta)
		#do not let the position move
		position.x = originalPos.x

