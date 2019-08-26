extends KinematicBody2D

var move : Vector2 = Vector2(0,0)
var speed : float = 200
var user_data : Dictionary setget set_user_data

func _ready():
	pass

func _physics_process(delta):
	move_and_slide(move.normalized() * speed)

master func update_keys(keys):
	move.y = int(keys["up"]) * -1 + int(keys["down"]) * 1
	move.x = int(keys["right"]) * 1 + int(keys["left"]) * -1

func set_user_data(dat : Dictionary):
	user_data = dat

puppet func move_update(pos: Vector2, mov : Vector2):
	var dist = (position - pos).length()
	
	if dist < 5:
		position = pos
	elif dist < 50:
		position += (pos - position)/(dist/ 4)
	else:
		position = pos
	
	move = mov
