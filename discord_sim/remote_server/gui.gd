extends Node

onready var da = $"../Data"
onready var di = $"../Discord"

var initialised = false

func _ready():
	set_process(false)

func start():
	if not initialised:
		var ts = da.teams
		var tmp = preload("res://remote_server/ui/team_edit.tscn")
		for t in ts:
			var t_edit = tmp.instance()
			$TeamsWindow/TabContainer.add_child(t_edit)
			t_edit.name = t
			t_edit.base = self
		set_process(true)
		initialised = true

func _process(delta):
	$RawUsers.text = str(da.users)
	var t = da.teams
	if not t.empty():
		for c in $TeamsWindow/TabContainer.get_children():
			if c.name == "template":
				c.queue_free()
			else:
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