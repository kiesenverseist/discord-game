extends Node

onready var da = $"../Data"

func _ready():
	pass

func _process(delta):
	return
	var t = da.teams
	$YellowPoints.text = "Yellow: " + str(t["Yellow"].points)

func _on_Exit_pressed():
	da.rpc("close_server")

func _on_Save_pressed():
	da.rpc("save_all")

func _on_AddYellow_pressed():
	var t = da.teams
	t["Yellow"].add_points(1)
	da.teams = t


func _on_OpenTeams_pressed():
	$TeamsWindow.popup()
