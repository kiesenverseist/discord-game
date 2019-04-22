extends Node

var teams = {}
var users = {}

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

class Team:
	var data = {}
	
	func _init(nam : String):
		data["name"] = nam
		data["points"] = 0
	
	func add_points(p : int):
		data["points"] += p
	
	func get_all() -> String:
		return JSON.print(data)
	
	func set_all(dat : String):
		var parsed = JSON.parse(dat).result
		
		#not directley equating incase anything new is not in the old save
		for key in parsed:
			data[key] = parsed[key]

class User:
	var data = {}
	
	func _init(id : String):
		data["id"] = id
	
	func set_nick(nick : String):
		data["nick"] = nick
	
	func set_avatar(avatar : String):
		data["avatar"] = avatar
	
	func set_all(dat : String):
		var parsed = JSON.parse(dat).result
		
		#not directley equating incase anything new is not in the old save
		for key in parsed:
			data[key] = parsed[key]

