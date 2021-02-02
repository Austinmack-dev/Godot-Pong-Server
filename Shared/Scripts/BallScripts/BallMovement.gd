extends KinematicBody2D

var moveDir = Vector2(-1,-1)

func _ready():
	pass
	
puppet func ball_move(pos,mvDir):
	position = pos
	moveDir = mvDir

#for processing physics
func _physics_process(delta):
	rpc_id(1,"_send_server_ball_move_info",moveDir,delta)
