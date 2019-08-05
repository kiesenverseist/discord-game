extends Node2D

var direction : Vector2 = Vector2(0,0)
var speed : float = 32
var title : String = ""

func _ready():
	pass

func _physics_process(delta):
	position += direction.normalized() * speed

func _set_all(data : Dictionary):
	name = data["name"]
	title = data["title"]
	position = data["position"]
	direction = data["direction"]
	speed = data["speed"]

func _to_string() -> String:
	return JSON.print({
		"name" : name,
		"title" : title,
		"position" : position,
		"direction" : direction,
		"speed" : speed
	})
