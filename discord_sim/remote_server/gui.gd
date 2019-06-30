extends Node

onready var da = $"../Data"
onready var di = $"../Discord"

func _ready():
	set_process(false)

func start():
	var ts = da.teams
	for t in ts:
		var nt = $TeamsWindow/TabContainer/template.duplicate()
		nt.name = t.name
	$TeamsWindow/TabContainer/template.queue_free()
	
	set_process(true)

func _process(delta):
	var t = da.teams
	for c in $TeamsWindow/TabContainer.get_children():
		c.get_node("Points").text = "Points: " + str(t[c.name].points)
		c.get_node("TeamChat").pressed = t[c.name].data["flag_chat"]
		c.get_node("VoiceChat").pressed = t[c.name].data["flag_vc"]

func _on_Exit_pressed():
	da.rpc("close_server")

func _on_Save_pressed():
	da.rpc("save_all")

func _on_OpenTeams_pressed():
	$TeamsWindow.popup()

func _on_EditPoints_pressed():
	var team = $TeamsWindow/TabContainer.get_current_tab_control().name
	var t = da.teams
	var num = int(get_node("TeamsWindow/TabContainer/%s/HBoxContainer/SpinBox" % team).get_line_edit().text)
	t[team].add_points(num)
	da.teams = t

func _on_UpdateLeaderboard_pressed():
	di.rpc_id(1, "update_leaderboard")

func _on_TeamChat_toggled(button_pressed):
	var team = $TeamsWindow/TabContainer.get_current_tab_control().name
	var t = da.teams
	t[team].data["flag_chat"] = button_pressed
	da.teams = t

func _on_VoiceChat_toggled(button_pressed):
	var team = $TeamsWindow/TabContainer.get_current_tab_control().name
	var t = da.teams
	t[team].data["flag_vc"] = button_pressed
	da.teams = t