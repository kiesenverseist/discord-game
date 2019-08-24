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
	
	var av_c = user_data["avatar_custom"]
	var av = av_c if not av_c in ["", "-", null] else user_data["avatar"]
	$URLSprite.url = user_data["avatar"]
