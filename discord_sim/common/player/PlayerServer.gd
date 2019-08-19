extends "player.gd"

var usr_id setget set_user
var ready = false

func _ready():
	ready = true
	get_node("/root/Main/Backend/Data").connect("users_updated", self, "request_user_update")

master func update_keys(keys : Dictionary):
	.update_keys(keys)
	rpc("move_update", position, move)

func _on_NetworkUpdate():
	rpc("move_update", position, move)

func set_user(usr):
	if not ready:
		yield(self, "ready")
	usr_id = usr
	request_user_update()

remote func request_user_update():
	var u = get_node("/root/Main/Backend/Data").users
	var user : User = u[usr_id]
	
	print("updating user data")
	set_user_data(user.data)
	rpc("set_user_data", user.data)
