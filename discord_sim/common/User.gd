extends Resource
class_name User

var data = {}

func _init(id : String):
	data["id"] = id
	data["user_name"] = ""
	data["nick"] = ""
	data["avatar"] = ""
	data["team"] = ""
	data["points"] = 0
	data["mention"] = ""

func set_nick(nick : String):
	data["nick"] = nick

func set_avatar(avatar : String):
	data["avatar"] = avatar

func get_all() -> String:
	return JSON.print(data)

func add_points(points : int):
	data["points"] += points

func set_all(dat : String):
	var parsed = JSON.parse(dat).result
	
	#not directley equating incase anything new is not in the old save
	for key in parsed:
		data[key] = parsed[key]