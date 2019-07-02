extends Node

func _ready():
	pass

#saving / sending/ updating
func get_all() -> String:
	return JSON.print({
		"MonsterFactory" : $MonsterFactory.get_all()
	})

func set_all(dat : String):
	var parsed = JSON.parse(dat).result
	
	#not directley equating incase anything new is not in the old save
	$MonsterFactory.set_all(parsed["MonsterFactory"])