extends Node

func _ready():
	pass

#saving / sending/ updating
func get_all() -> String:
	print($MonsterFactory)
	return JSON.print({
		"MonsterFactory" : $MonsterFactory.get_all(),
		"TempInstances" : str($TempInstances)
	})

func set_all(dat : String):
	yield(self, "ready")
	var parsed = JSON.parse(dat).result
	
	if parsed.has("MonsterFactory"):
		$MonsterFactory.set_all(parsed["MonsterFactory"])
	if parsed.has("TempInstances"):
		$TempInstances.set_all(parsed["TempInstances"])
