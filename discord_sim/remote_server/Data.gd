extends Node

var teams : Dictionary = {} setget set_teams, get_teams
var users : Dictionary = {} setget set_users, get_users

func set_teams(t_dict : Dictionary = teams):
	var t_data : Dictionary
	for t in t_dict:
		t_data[t] = t_dict[t].get_all()
	var t_str = JSON.print(t_data)
	rpc("set_networked_teams", t_str)
	printt("setting teams as remote", t_str)

remotesync func set_networked_teams(t_str : String):
	var t = JSON.parse(t_str).result
	for team in t:
		var t_new = Team.new(team)
		t_new.set_all(t[team])
		teams[team] = t_new
		
	printt("teams set by server", t)
	
	$"../GUI".start()

func get_teams() -> Dictionary:
	return teams

func set_users(u_dict : Dictionary = users):
	var u_data : Dictionary
	for u in u_dict:
		u_data[u] = u_dict[u].get_all()
	var u_str = JSON.print(u_data)
	rpc("set_networked_users", u_str)
	printt("setting users from server", u_str)

remotesync func set_networked_users(u_str : String):
	var u = JSON.parse(u_str).result
	for user in u:
		var u_new = User.new(user)
		u_new.set_all(u[user])
		users[user] = u_new
	printt("users set", u)

func get_users() -> Dictionary:
	return users
