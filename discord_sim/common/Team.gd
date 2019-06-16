extends Resource
class_name Team

var data = {}

var points setget ,get_points
var name setget ,get_name

func _init(nam : String):
	data["name"] = nam
	data["points"] = 0

func add_points(p : int = 1):
	data["points"] += p

func get_points() -> int:
	return data["points"]

func get_name() -> String:
	return data["name"]

func get_all() -> String:
	return JSON.print(data)

func set_all(dat : String):
	var parsed = JSON.parse(dat).result
	
	#not directley equating incase anything new is not in the old save
	for key in parsed:
		data[key] = parsed[key]