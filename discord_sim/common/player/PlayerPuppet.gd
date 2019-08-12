extends "player.gd"

func _ready():
	pass

puppet func move_update(pos : Vector2, mov : Vector2):
	position = pos
	move = mov

puppet func set_user_data(dat):
	.set_user_data(dat)
	
	$Label.text = user_data["user_name"]
