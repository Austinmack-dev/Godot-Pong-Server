extends KinematicBody2D

var moveSpeed = 100
var ball_move_queue = Array()
var move_dir_server = Vector2()
#var velocity = Vector2()

master func _send_server_ball_move_info(moveDir,delta):
	var sender_id = get_tree().multiplayer.get_rpc_sender_id()
	if(Networking.player_info.has(sender_id)):
		move_dir_server = moveDir
		var velocity = move_dir_server * moveSpeed
		var coll = move_and_collide(velocity*delta)
		if(coll):
			velocity = velocity.bounce(coll.normal)
			move_dir_server = move_dir_server.bounce(coll.normal)
		rpc("ball_move",position,move_dir_server)
	
func _physics_process(delta):
	pass
#	var curr = ball_move_queue.pop_back()
#	var coll = move_and_collide(curr*delta)
#	if coll:
#		velocity = velocity.bounce(coll.normal)
#
#	rpc("ball_move",position)
		