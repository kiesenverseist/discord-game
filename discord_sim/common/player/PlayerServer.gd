extends "player.gd"

var usr_id : String = "" setget set_user

func _ready():
	pass

master func update_keys(keys : Dictionary):
	.update_keys(keys)
	rpc("move_update", position, move)

func _on_NetworkUpdate():
	rpc("move_update", position, move)

func set_user(usr):
	yield(self, "ready")
	var u = get_tree().get_child("Main/Backend/Data").users
	var user : User = u[usr]
	set_user_data(user.data)
	rpc("set_user_data", user.data)
