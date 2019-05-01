extends TabContainer

onready var gd = $"../../GlobalData"
onready var mg = $"../../Manager"

func _ready():
	pass # Replace with function body.

func _process(delta):
	for c in get_children():
		c.get_node("Points").text = "Points: " + str(gd.teams[c.name].get_points())

func change_points(team_name : String, num : int):
	gd.teams[team_name].add_points(num)
	mg.update_leaderboard()
