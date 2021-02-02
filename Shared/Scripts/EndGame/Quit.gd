extends Button

var player_network_id

func _ready():
	var lobby = get_node("/root/LobbyNode")
	player_network_id = lobby.my_id


func _on_Quit_pressed():
	#Networking.rpc_id(1,"_end_game_button_press",name, player_network_id)
	get_tree().multiplayer.set_network_peer(null)
	get_tree().quit()
	
