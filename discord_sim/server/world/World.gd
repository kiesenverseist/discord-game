extends Node

func _ready():
	pass

#saving / sending/ updating
func get_all() -> String:
	return JSON.print({
		"MonsterFactory" : $MonsterFactory.get_all(),
		"TempInstances" : str($TempInstances)
	})

func set_all(dat : String):
	yield(self, "ready")
	var parsed = JSON.parse(dat).result
	
	if parsed.has("MonsterFactpry"):
		$MonsterFactory.set_all(parsed["MonsterFactory"])
	if parsed.has("TempInstances"):
		$TempInstances.set_all(parsed["TempInstances"])
