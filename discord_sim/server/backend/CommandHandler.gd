extends Node

onready var ws = $"../../Websocket"
onready var da = $"../../Data"
onready var di = get_parent()
onready var mh = $"../MessageHandler"

var command_symbol = "%"

var commands = {
	"update_leaderboard" : funcref(self, "update_leaderboard"),
	"update_users" : funcref(self, "update_users"),
	"update_user_leaderboard" : funcref(self, "update_user_leaderboard")
}

func _ready():
	pass
#	handle_command({
#		"message" : "^cmd"
#	})

func handle_command(data):
	if  not data["message"].begins_with(command_symbol):
		return
	
	var command : String = data["message"].lstrip(command_symbol).split(" ", true, 1)[0]
	
	var arguments : PoolStringArray = data["message"].lstrip(command_symbol+command).split(",", true)
	
	var i = 0
	for arg in arguments:
		arguments[i] = (arg as String).strip_edges().strip_escapes()
		i += 1
	
	printt("command:", command, arguments)
	
	if commands.has(command):
		commands[command].call_func(data, arguments)
	else:
		di.discord_message("invalid command", data["channel_name"], data["category_name"])

## commands
# admin
func update_leaderboard(data, arguments):
	if is_dm(data):
		di.discord_message("This command cannot be used in DMs.", data["channel_name"], data["category_name"])
		return
	
	if not is_admin(data):
		di.discord_message("Must be whitelisted to use command.", data["channel_name"], data["category_name"])
		return

	di.update_leaderboard()
	di.discord_message("Leaderboard updated.", data["channel_name"], data["category_name"])

func update_users(data, arguments):
	if is_dm(data):
		di.discord_message("This command cannot be used in DMs.", data["channel_name"], data["category_name"])
		return
	
	if not is_admin(data):
		di.discord_message("Must be whitelisted to use command.", data["channel_name"], data["category_name"])
		return
	
	di.update_users()
	di.discord_message("Users updated.", data["channel_name"], data["category_name"])

func update_user_leaderboard(data, arguments):
	if is_dm(data):
		di.discord_message("This command cannot be used in DMs.", data["channel_name"], data["category_name"])
		return
	
	if not is_admin(data):
		di.discord_message("Must be whitelisted to use command.", data["channel_name"], data["category_name"])
		return
		
	di.update_user_leaderboard(data)
	di.discord_message("Users posted.", data["channel_name"], data["category_name"])

#dm


#general


## util functions
func is_admin(data) -> bool:
	return data["user_id"] in ["183363112882274305", "186298188800458752"]

func is_dm(data) -> bool:
	return data["is_dm"]
