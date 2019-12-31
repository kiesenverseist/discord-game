extends Resource
class_name User

var data = {}
var points setget ,get_points
var token setget ,get_token

func _init(id : String):
	data["id"] = id
	data["user_name"] = ""
	data["nick"] = ""
	data["avatar"] = ""
	data["avatar_custom"] = ""
	data["team"] = ""
	data["points"] = 0
	data["mention"] = ""
	data["max_hp"] = 5
	data["hp"] = data["max_hp"]
	data["position"] = Vector2(0,0)

func set_nick(nick : String):
	data["nick"] = nick

func set_avatar(avatar : String):
	data["avatar"] = avatar

func get_all() -> String:
	return var2str(data)

func add_points(points : int):
	data["points"] += points

func get_points():
	return data["points"]

func get_token():
	return hash(str(data["id"]))

func set_all(dat : String):
	data = str2var(dat)

func _to_string() -> String:
	return get_all()
