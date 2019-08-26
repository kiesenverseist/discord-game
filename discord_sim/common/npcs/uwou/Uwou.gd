extends KinematicBody2D

var direction : Vector2 = Vector2(0,0)
var speed : float = 32
var title : String = ""
sync var points : int = 0
var max_health : int = 10
var health = max_health

signal drop_points

func _ready():
	pass

func _physics_process(delta):
	move_and_slide(direction.normalized() * speed)

func damage(amount):
	health -= amount
	
	if health <= 0:
		emit_signal("drop_points", position, points)
		points = 0
		die()
		rpc("die")

remote func die():
	print("an uwou dieded")
	queue_free()

func _set_all(dat : String):
	var data : Dictionary= JSON.parse(dat).result
	name = data["name"]
	title = data["title"]
	position = str2var(data["position"])
	direction = str2var(data["direction"])
	speed = float(data["speed"])
	points = int(data["points"])
	max_health = int(data.get("max_health", 10))
	health = int(data.get("health", max_health))

func _to_string() -> String:
	return JSON.print({
		"name" : name,
		"title" : title,
		"position" : var2str(position),
		"direction" : var2str(direction),
		"speed" : speed,
		"points" : points,
		"max_health" : max_health,
		"health" : health
	})
