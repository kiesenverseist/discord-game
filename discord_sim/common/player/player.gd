extends Node2D

var move : Vector2 = Vector2(0,0)
var speed : float = 200
var user_data : Dictionary setget set_user_data

func _ready():
	pass

func _physics_process(delta):
	position += move.normalized() * speed * delta

master func update_keys(keys):
	move.y = int(keys["up"]) * -1 + int(keys["down"]) * 1
	move.x = int(keys["right"]) * 1 + int(keys["left"]) * -1

func set_user_data(dat : Dictionary):
	user_data = dat
