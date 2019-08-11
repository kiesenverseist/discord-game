extends "Uwou.gd"

func _ready():
	direction = Vector2(1,0).rotated(rand_range(0, 2*PI))

func move():
	direction = direction.rotated(rand_range(-0.1, 0.1))
	if custom_multiplayer != null:
		rpc("move", position, direction)
