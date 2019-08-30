extends "player.gd"

signal user_data_set(dat)
signal team_data_set(dat)

var keys : Dictionary = {
	"up" : false,
	"down" : false,
	"right" : false,
	"left" : false,
	"shoot" : false
}

func _ready():
	rpc_id(1, "request_user_update")

func _unhandled_input(event):
	var old_keys = keys.duplicate(true)
	
	if event.is_action_pressed("move_up"):
		keys["up"] = true
	if event.is_action_released("move_up"):
		keys["up"] = false
	
	if event.is_action_pressed("move_down"):
		keys["down"] = true
	if event.is_action_released("move_down"):
		keys["down"] = false
	
	if event.is_action_pressed("move_right"):
		keys["right"] = true
	if event.is_action_released("move_right"):
		keys["right"] = false
	
	if event.is_action_pressed("move_left"):
		keys["left"] = true
	if event.is_action_released("move_left"):
		keys["left"] = false
	
	if event.is_action_pressed("shoot"):
		keys["shoot"] = true
	if event.is_action_released("shoot"):
		keys["shoot"] = false
	
	if hash(old_keys) != hash(keys):
		if multiplayer.network_peer:
			rpc_id(1, "update_keys", keys)
		
		update_keys(keys)

puppet func set_user_data(dat):
	.set_user_data(dat)
	emit_signal("user_data_set", dat)
	
	var av_c = user_data["avatar_custom"]
	var av = av_c if not av_c in ["", "-", null] else user_data["avatar"]
	$URLSprite.url = av

remote func set_team_data(dat : String):
	emit_signal("team_data_set", dat)
