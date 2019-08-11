extends Node2D

var direction : Vector2 = Vector2(0,0)
var speed : float = 32
var title : String = ""

func _ready():
	pass

func _physics_process(delta):
	position += direction.normalized() * speed * delta
	
	if abs(position.x) > 1000 or abs(position.y) > 1000:
		direction = -direction

func _set_all(data):
	data = JSON.parse(data).result
	name = data["name"]
	title = data["title"]
	position = str2var(data["position"])
	direction = str2var(data["direction"])
	speed = float(data["speed"])
	

func _to_string() -> String:
	return JSON.print({
		"name" : name,
		"title" : title,
		"position" : var2str(position),
		"direction" : var2str(direction),
		"speed" : speed
	})
