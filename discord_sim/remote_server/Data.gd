extends Node

remotesync var _networked_teams setget set_networked_teams

var teams = {} setget set_teams, get_teams
var users = {} setget set_users, get_users

func set_teams(t = teams):
	rset("networked_teams", t)
	printt("setting teams", t)

func set_networked_teams(t):
	teams = t
	_networked_teams = t

func get_teams():
	return teams

func set_users(u = users):
	rset("users", u)

func get_users():
	return users