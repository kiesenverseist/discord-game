extends KinematicBody2D

var direction : Vector2 = Vector2(0,0)
var speed : float = 32
var title : String = ""
sync var points : int = 0
var max_health : int = 1
var health = 1

signal drop_points

func _ready():
	pass

func _physics_process(delta):
	move_and_slide(direction.normalized() * speed)

func damage(amount):
	health -= amount
	
	if health <= 0:
		emit_signal("drop_points", position, points)
		

func _set_all(data):
	data = JSON.parse(data).result
	name = data["name"]
	title = data["title"]
	position = str2var(data["position"])
	direction = str2var(data["direction"])
	speed = float(data["speed"])
	points = int(data["points"])

func _to_string() -> String:
	return JSON.print({
		"name" : name,
		"title" : title,
		"position" : var2str(position),
		"direction" : var2str(direction),
		"speed" : speed,
		"points" : points
	})
