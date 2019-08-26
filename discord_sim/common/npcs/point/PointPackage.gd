extends Area2D

var points = 1

func _on_PointPackage_body_entered(body):
	if is_network_master() and body.has_method("give_points"):
		body.give_points(points)
		remove()
		rpc("remove")

remote func remove():
	queue_free()

func _set_all(data : String) -> void:
	var dat = JSON.parse(data).result
	position = str2var(dat["pos"])
	points = int(dat["points"])

func _to_string() -> String:
	return JSON.print({
		"type" : "PointPackage",
		"pos" : var2str(position),
		"points" : points
	})
