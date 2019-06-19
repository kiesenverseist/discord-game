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
	
	$"../GUI".set_process(true)

func get_teams() -> Dictionary:
	return teams

func set_users(u : Dictionary = users):
	rset("users", u)

func get_users() -> Dictionary:
	return users
