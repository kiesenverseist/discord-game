extends Node

func _ready():
	pass # Replace with function body.

func connected():
	$MonsterFactory.connected()
	$TempInstances.request_sync()
