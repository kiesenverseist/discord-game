extends Node

var point_package = preload("res://common/npcs/point/PointPackage.tscn")
var bullet = preload("res://common/npcs/bullet/Bullet.tscn")

# this script is a little differet. so are point packages and
# bullets. Im trying out putting both the network and client
# side stuff in one scene / script. This should be fine for
# smaller stuff where the code isn't as long.

func _ready():
	spawn_thing()

func spawn_thing():
	print("spawn point package")
	get_tree().create_timer(1000).connect("timeout", self, "spawn_thing")
	drop_points(Vector2(rand_range(-1000,1000), rand_range(-1000,1000)), randi()%3+1)

# call this function to create a point package across everything
func drop_points(pos : Vector2, points : int) -> void:
	rpc("network_drop_points", pos, points)

sync func network_drop_points(pos : Vector2, points : int) -> void:
	var pp = point_package.instance()
	pp.position = pos
	pp.points = points
	add_child(pp, true)

# call this to make a bullet everywhere
func shoot_bullet(pos: Vector2, dir : Vector2) -> void:
	rpc("network_shot_bullet", pos, dir)

sync func network_shoot_bullet(pos : Vector2, dir : int) -> void:
	var b = bullet.instance()
	b.position = pos
	b.direction = dir
	add_child(b, true)

func request_sync() -> void:
	rpc_id(1, "give_sync")

master func give_sync(id : int) -> void:
	rpc_id(id, "recieve_sync", str(self))

puppet func recieve_sync(data : String) -> void:
	set_all(data)

func set_all(data : String) -> void:
	var dat = JSON.parse(data).result
	
	var entities = dat["entities"]
	for e in entities:
		var type = JSON.parse(entities[e]).result["type"]
		match type:
			"PointPackage":
				var pp = point_package.instance()
				pp._set_all(entities[e])
				pp.name = e
				add_child(pp, true)
			"Bullet":
				var b = bullet.instance()
				b._set_all(entities[e])
				b.name = e
				add_child(b, true)
			_:
				printerr("type not matched in temp instance creator")

func _to_string() -> String:
	var data = {
		"entities" : {}
	}
	
	for c in get_children():
		data["entities"][c.name] = str(c)
	
	return JSON.print(data) 
