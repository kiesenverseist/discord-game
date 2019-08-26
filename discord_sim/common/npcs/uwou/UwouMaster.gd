extends "Uwou.gd"

var sub_point = 3

func _ready():
	direction = Vector2(1,0).rotated(rand_range(0, 2*PI))

func give_point(amount):
	points += amount

func move():
	direction = direction.rotated(rand_range(-0.1, 0.1))
	if custom_multiplayer != null:
		rpc("move", position, direction)

func _on_PointCountdown_timeout():
	sub_point -= 1
	
	if sub_point <= 0:
		points += 1
		rset("points", points)
		sub_point = randi()%9 + 1
