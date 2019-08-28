extends KinematicBody2D

var speed = 80
var direction = Vector2(1,0)

func _ready():
	pass

func _physics_process(delta):
	var col = move_and_collide(direction.normalized() * speed)
	
	if is_network_master() and col.remainder != Vector2(0,0):
		var obj = col.collider
		
		if obj.has_method("damage"):
			obj.damage(1)
		
		queue_free()

func _set_all(data : String) -> void:
	var dat = JSON.parse(data).result
	position = str2var(dat["pos"])
	direction = str2var(dat["dir"])

func _to_string() -> String:
	return JSON.print({
		"type" : "PointPackage",
		"pos" : var2str(position),
		"dir" : var2str(direction)
	})
