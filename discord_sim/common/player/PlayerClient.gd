extends "player.gd"

var keys : Dictionary = {
	"up" : false,
	"down" : false,
	"right" : false,
	"left" : false
}

func _ready():
	pass # Replace with function body.

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
	
	if hash(old_keys) != hash(keys):
		if multiplayer.network_peer:
			rpc_id(1, "update_keys", keys)
		
		update_keys(keys)

puppet func move_update(pos : Vector2, mov : Vector2):
	position = pos
	move = mov

puppet func set_user_data(dat):
	printt("user data updated", dat)
	.set_user_data(dat)
