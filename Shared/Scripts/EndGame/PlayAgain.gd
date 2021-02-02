extends Button

var player_network_id = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	var lobby = get_node("/root/LobbyNode")
	player_network_id = lobby.my_id




func _on_PlayAgain_pressed():
	Networking.rpc_id(1,"_end_game_button_press",name, player_network_id)
