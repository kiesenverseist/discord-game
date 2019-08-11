extends Node

func _ready():
	pass

#saving / sending/ updating
func get_all() -> String:
	return JSON.print({
		"MonsterFactory" : $MonsterFactory.get_all()
	})

func set_all(dat : String):
	yield(self, "ready")
	var parsed = JSON.parse(dat).result
	
	$MonsterFactory.set_all(parsed["MonsterFactory"])
