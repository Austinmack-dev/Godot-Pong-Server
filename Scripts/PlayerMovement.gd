extends KinematicBody2D

var player_pos = Vector2()
var player_pos_queue = Array()
var playerMoveSpeed = 350
var clients_id = 0
var originalPos

# Called when the node enters the scene tree for the first time.
func _ready():
	originalPos = position


master func _send_server_movement_data(moveDir,client_id,delta):
	var sender_id = get_tree().multiplayer.get_rpc_sender_id()
	if(Networking.player_info.has(sender_id)):
		move_and_collide(Vector2(0,moveDir).normalized()*delta*playerMoveSpeed)
		position.x = originalPos.x
		rpc("_move_player",position,client_id)