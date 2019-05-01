extends Node

var teams = {}
var users = {}

onready var ws = $"../Websocket"

func _ready():
	var savefile = File.new()
	if savefile.file_exists("user://game.save"):
		load_all()
	else:
		teams["Red"] = Team.new("Red")
		teams["Green"] = Team.new("Green")
		teams["Blue"] = Team.new("Blue")
		teams["Yellow"] = Team.new("Yellow")
	savefile.close()
	
	get_tree().create_timer(3600).connect("timeout", self, "autosave")

func autosave():
	save_all()
	get_tree().create_timer(3600).connect("timeout", self, "autosave")

func save_all():
	var data = {}
	
	var ts = {}
	for t in teams:
		ts[t] = teams[t].get_all()
	
	var us = {}
	for u in users:
		us[u] = users[u].get_all()
	
	data["teams"] = ts
	data["users"] = us
	
	var data_string = JSON.print(data)
	
	var save_game = File.new()
	save_game.open("user://game.save", File.WRITE)
	save_game.store_line(data_string)
	save_game.close()
	
	print("data saved")

func load_all():
	var save_game = File.new()
	save_game.open("user://game.save", File.READ)
	var data_string = save_game.get_line()
	save_game.close()
	
	var data = JSON.parse(data_string).result
	
	var ts = data["teams"]
	for t in ts:
		teams[t] = Team.new(t)
		teams[t].set_all(ts[t])
	
	var us = data["users"]
	for u in us:
		users[u] = User.new(u)
		users[u].set_all(us[u])
	
	print("done loading")

func add_user(id : String, nam : String):
	users[id] = User.new(id, nam)

func remove_user(id : String):
	users.erase(id)

class Team:
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

class User:
	var data = {}
	
	func _init(id : String, nam : String = ""):
		data["id"] = id
		data["user_name"] = nam
	
	func set_nick(nick : String):
		data["nick"] = nick
	
	func set_avatar(avatar : String):
		data["avatar"] = avatar
	
	func get_all() -> String:
		return JSON.print(data)
	
	func set_all(dat : String):
		var parsed = JSON.parse(dat).result
		
		#not directley equating incase anything new is not in the old save
		for key in parsed:
			data[key] = parsed[key]

func _on_ToolButton_pressed():
	ws.close()
	save_all()
	get_tree().quit()
