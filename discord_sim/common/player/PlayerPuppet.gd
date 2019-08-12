extends "player.gd"

func _ready():
	connect("renamed", self, "renamed")
	renamed(name)

puppet func move_update(pos : Vector2, mov : Vector2):
	position = pos
	move = mov

func renamed(nm : String):
	name = nm
	$Label.text = user_data["user_name"]

puppet func set_user_data(dat):
	.set_user_data(dat)
	
	renamed(name)
