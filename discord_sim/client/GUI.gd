extends CanvasLayer

func _ready():
	pass # Replace with function body.

func update_gui():
	var data = $"../".user_data
	var t = $"../".team
	
	$HBoxContainer/Points.text = "Personal Points: " + str(data["points"])
	$HBoxContainer/Team.text = "Team: " + data["team"]
	$HBoxContainer/TeamPoints.text = "Team Points: " + str(t.points)
	$HBoxContainer/Health.text = "Health: " + str(data["health"]) + "/" + str(data["max_health"])
