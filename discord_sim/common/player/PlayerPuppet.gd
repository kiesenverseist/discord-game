extends "player.gd"

var ready

func _ready():
	rpc_id(1, "request_user_update")

puppet func move_update(pos : Vector2, mov : Vector2):
	position = pos
	move = mov

puppet func set_user_data(dat):
	.set_user_data(dat)
	
	$PlayerName.text = user_data["user_name"]
	$PlayerTeam.text = user_data["team"]
