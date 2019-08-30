extends "player.gd"

var usr_id setget set_user
var ready = false

func _ready():
	ready = true
	get_node("/root/Main/Backend/Data").connect("users_updated", self, "request_user_update")

func give_points(amount : int) -> void:
	var u = get_node("/root/Main/Backend/Data").users
	u[usr_id].add_points(amount)
	get_node("/root/Main/Backend/Data").users = u

func kill():
	var pts = user_data["points"]/2
	emit_signal("drop_points", pts)
	var u = get_node("/root/Main/Backend/Data").users
	u[usr_id].add_points(-pts)
	get_node("/root/Main/Backend/Data").users = u
	
	.kill()

master func update_keys(keys : Dictionary):
	.update_keys(keys)
	rpc("move_update", position, move)
	
	.shoot(keys)

func _on_NetworkUpdate():
	rpc("move_update", position, move)

func set_user(usr):
	if not ready:
		yield(self, "ready")
	usr_id = usr
	request_user_update()

remote func request_user_update():
	var u = get_node("/root/Main/Backend/Data").users
	var t = get_node("/root/Main/Backend/Data").teams
	var user : User = u[usr_id]
	var team : Team = t[user.data["team"]]
	
	print("updating user data")
	set_user_data(user.data)
	rpc("set_user_data", user.data)
	rpc_id(int(name), "set_team_data", str(team))
