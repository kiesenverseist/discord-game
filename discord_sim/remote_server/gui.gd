extends Node

onready var da = $"../Data"

func _ready():
	set_process(false)

func _process(delta):
	var t = da.teams
	$YellowPoints.text = "Yellow: " + str(t["Yellow"].points)
	for c in $TeamsWindow/TabContainer.get_children():
		c.get_node("Points").text = c.name + ": " + str(t[c.name].points)

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

func _on_EditPoints_pressed():
	var team = $TeamsWindow/TabContainer.get_current_tab_control().name
	var t = da.teams
	var num = int(get_node("TeamsWindow/TabContainer/%s/HBoxContainer/SpinBox" % team).get_line_edit().text)
	t[team].add_points(num)
	da.teams = t
