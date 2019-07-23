extends Resource
class_name Team

var data = {}

var points setget ,get_points
var name setget ,get_name

func _init(nam : String):
	data["name"] = nam
	data["points"] = 0
	data["flag_chat"] = false
	data["flag_vc"] = false
	data["flag_user_leaderboard"] = false

func add_points(p : int = 1):
	data["points"] += p
	eval_flags()

func get_points() -> int:
	return data["points"]

func get_name() -> String:
	return data["name"]

func eval_flags():
	var pts = self.points
	
	data["flag_chat"] = pts >= 10
	data["flag_vc"] = pts >= 50
	data["flag_user_leaderboard"] = pts >= 75

#saving / sending/ updating
func get_all() -> String:
	return JSON.print(data)

func set_all(dat : String):
	var parsed = JSON.parse(dat).result
	
	#not directley equating incase anything new is not in the old save
	for key in parsed:
		data[key] = parsed[key]

func _to_string() -> String:
	return get_all()
