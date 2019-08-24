extends Node

onready var ws = $"../../Websocket"
onready var da = $"../../Data"
onready var di = get_parent()
onready var mh = $"../MessageHandler"

var command_symbol = "%"

var commands = {
	"update_leaderboard" : funcref(self, "update_leaderboard"),
	"update_users" : funcref(self, "update_users"),
	"update_user_leaderboard" : funcref(self, "update_user_leaderboard"),
	"avatar" : funcref(self, "avatar"),
	"token" : funcref(self, "token"),
	"points" : funcref(self, "get_points")
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
		arguments[i] = (arg as String).strip_edges()
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
func token(data, arguments):
	if not is_dm(data):
		di.discord_message("This command can only be used in DMs.", data["channel_name"], data["category_name"])
		return
	
	var u = da.users
	di.discord_message_id("Your token is: " + str(u[data["user_id"]].token, data["channel_id"]))

func avatar(data, arguments):
	if not is_dm(data):
		di.discord_message("This command can only be used in DMs.", data["channel_name"], data["category_name"])
		return
	
	var u = da.users
	if arguments[0]:
		var url = (arguments[0] as String)
		u[data["user_id"]].data["avatar_custom"] = url
	
	var av = u[data["user_id"]].data["avatar"] 
	var av_c = u[data["user_id"]].data["avatar_custom"] + "\nUse the command `^avatar <url>` to change to <url>"
	av = av_c  + "\nUse the command `^avatar -` to reset to default" \
			if not av_c in ["-", "", null] else av
	
	di.discord_message_id("Your current profile is: " + av, data["channel_id"])

#general
func get_points(data, arguments):
	var t = da.teams
	var u = da.users

	di.discord_message("Your team has %s points" % str(t[u[data["user_id"]].data["team"]].points)\
			+ "\nYou have %s points" % str(u[data["user_id"]].points),\
			data["channel_name"], data["category_name"])

## util functions
func is_admin(data) -> bool:
	return data["user_id"] in ["183363112882274305", "186298188800458752"]

func is_dm(data) -> bool:
	return data["is_dm"]
