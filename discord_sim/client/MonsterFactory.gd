extends Node

onready var uwou_pk = preload("res://common/npcs/uwou/UwouPuppet.tscn")

func _ready():
	pass

remote func spawn(creature):
	var uwou = uwou_pk.instance()
	uwou._set_all(creature)
	add_child(uwou)

func connected():
	rpc_id(1, "request_sync", multiplayer.get_network_unique_id())

remote func synchronise(monsters):
	for c in get_children():
		c.queue_free()
	
	for m in monsters:
		var uwou = uwou_pk.instance()
		uwou._set_all(monsters[m])
		add_child(uwou)
		
	print(get_children())
