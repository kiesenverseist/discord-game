extends Node

var to_spawn_uowu : bool = false
var next_uwou_spawn : int = 0
export var uwou_cooldown : int = 3600*24

onready var di = $"../../Discord"

func _ready():
	spawn_loop()

func try_spawn_uwou():
	to_spawn_uowu = true

func spawn_uwou():
	var messages = [
		"A deep rumble is heard from deep within the maze",
		"The floor trembles",
		"Beware the creatures of the maze, a new beast rises",
		"Small critters flee the maze",
		"The maze feels darker than before"
	]
	di.discord_message(messages[randi()%messages.size()],"events","Diplomacy")

func spawn_loop():
	var curr_time = OS.get_unix_time()
	
	if to_spawn_uowu and next_uwou_spawn < curr_time:
		to_spawn_uowu = false
		next_uwou_spawn = curr_time + uwou_cooldown
		spawn_uwou()
	
	get_tree().create_timer(60).connect("timeout", self, "spawn_loop")

#saving / sending/ updating
func get_all() -> String:
	return JSON.print({
		"next_uwou_spawn" : str(next_uwou_spawn),
		"to_spawn_uwou" : str(to_spawn_uwou)
	})

func set_all(dat : String):
	var parsed = JSON.parse(dat).result
	
	next_uwou_spawn = int(parsed["next_uwou_spawn"])
	to_spawn_uowu = bool(to_spawn_uowu)