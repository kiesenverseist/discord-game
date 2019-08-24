extends Node

onready var ws = $"../../Websocket"
onready var da = $"../../Data"
onready var di = get_parent()
onready var ch = $"../CommandHandler"

var regex = {
	uwou = RegEx.new()
}

var spy_cooldown : bool = true

func _ready():
	regex.uwou.compile("[uUwWoO0]{3}")

func handle_message(data):
#	if data["message"].begins_with("^"):
#		admin_command(data)
	
	if not data["is_dm"]:
		
		#uwou detector
		var uwou_data = regex.uwou.search_all(data["message"])
		if uwou_data.size() > 5:
			var reply = {
				"type" : "message",
				"channel_name" : data["channel_name"],
				"category_name": data["category_name"],
				"message" : "I refuse."
			}
			ws.send_data(reply)
			yield(get_tree().create_timer(uwou_data.size() * 2), "timeout")
			reply = {
				"type" : "message",
				"channel_name" : data["channel_name"],
				"category_name": data["category_name"],
				"message" : "<%s seconds>\n\n*Sigh*" % str(uwou_data.size() * 2)
			}
			ws.send_data(reply)
			
		if not uwou_data.empty():
			var ret = ""
			for res in uwou_data:
				ret += res.get_string() + " "
			var reply = {
				"type" : "message",
				"channel_name" : data["channel_name"],
				"category_name": data["category_name"],
				"message" : ret + "What's this?"
			}
			ws.send_data(reply)
			$"../../../Playerend/World/MonsterFactory".try_spawn_uwou()
		
		if data["message"].matchn("*kys*"):
			var reply = {
				"type" : "message",
				"channel_name" : data["channel_name"],
				"category_name": data["category_name"]
			}
			if data["message"].matchn("*kysenverseist*"):
				var replies = ["No u","*Kiesenverseist", "No.", "staph"]
				reply["message"] = replies[randi()%replies.size()]
			else:
				var replies = ["Pls noe", "Be nice", "Be kind", "Please be careful"]
				reply["message"] = replies[randi()%replies.size()]
			ws.send_data(reply)
			
		if data["message"].matchn("*c*r*e*e*p*e*r*"):
			ws.send_data({
				"type" : "message",
				"message" : "Aww man!",
				"channel_name" : data["channel_name"],
				"category_name": data["category_name"]
			})
		
		match data["channel_name"]:
			"generator":
				var sabotage_attempted = sabotage(data)
				
				if sabotage_attempted:
					#give user point
					var us = da.users
					us[data["user_id"]].add_points(1)
					da.users = us
					
					var t = da.teams
					if randf() < 0.08:
						t[data["category_name"]].add_points(3)
						var reply = {
							"type" : "message",
							"channel_name" : data["channel_name"],
							"category_name": data["category_name"],
							"message" : "Critical Success!"
						}
						ws.send_data(reply)
					elif randf() < 0.01:
						t[data["category_name"]].add_points(-3)
						var reply = {
							"type" : "message",
							"channel_name" : data["channel_name"],
							"category_name": data["category_name"],
							"message" : "Critical Failure!"
						}
						ws.send_data(reply)
					else:
						t[data["category_name"]].add_points(1)
					da.teams = t
				
				#for when a team surpasses 100
#				if t[data["category_name"]].points >= 100 and t[data["category_name"]].points <= 101 :
#					var reply = {
#						"type" : "message",
#						"channel_name" : "announcements",
#						"category_name": "Super",
#						"message" : "Congradulations to %s for reaching 100 points!\nhttps://www.youtube.com/watch?v=1Bix44C1EzY" % data["category_name"]
#					}
#					ws.send_data(reply)
			
			"team-chat":
				if data["message"].matchn("*p*o*i*n*t*"):
					var t = da.teams
					var u = da.users
					var reply = {
						"type" : "message",
						"channel_name" : data["channel_name"],
						"category_name": data["category_name"],
						"message" : "Your team has %s points" % str(t[data["category_name"]].points)\
								+ "\nYou have %s points" % str(u[data["user_id"]].data["points"])
					}
					ws.send_data(reply)
				
				var other_teams = da.teams.keys()
				other_teams.erase(data["category_name"])
				
				for team in other_teams:
					if data["message"].matchn("*%s*" % team):
						try_spy(data, team)
				
				if randf() < 0.001:
					var t = da.teams
					t[data["category_name"]].add_points(1)
					da.teams = t
					
					var reply = {
						"type" : "message",
						"channel_name" : data["channel_name"],
						"category_name": data["category_name"],
						"message" : "You found a point."
					}
					ws.send_data(reply)
	
	else: # is a dm
		if data["message"].begins_with("^"):
			var cmd = data["message"].lstrip("^").split(" ", true, 2)
			if cmd[0].matchn("token"):
				var u = da.users
				ws.send_data({
					"type" : "message",
					"channel_id" : data["channel_id"],
					"message" : "Your token is: " + str(u[data["user_id"]].token)
				})
			if cmd[0].matchn("avatar"):
				var u = da.users
				if len(cmd) > 1:
					var url = (cmd[1] as String).strip_edges()
					u[data["user_id"]].data["avatar_custom"] = url
				
				var av = u[data["user_id"]].data["avatar"] 
				var av_c = u[data["user_id"]].data["avatar_custom"] + "\nUse the command `^avatar <url>` to change to <url>"
				av = av_c  + "\nUse the command `^avatar -` to reset to default" \
						if not av_c in ["-", "", null] else av
				ws.send_data({
					"type" : "message",
					"channel_id" : data["channel_id"],
					"message" : "Your current profile is: " + av
				})
		else:
			var reply_dm = {}
			reply_dm["type"] = "message"
			reply_dm["channel_id"] = data["channel_id"]
			reply_dm["message"] = "Plox noe dm ;-;"
			ws.send_data(reply_dm)

func admin_command(data):
	if not data["user_id"] in ["183363112882274305", "186298188800458752"]:
		return
	
	if data["message"].matchn("*update_leaderboard*"):
		di.update_leaderboard()
		di.discord_message("leaderboard updated", data["channel_name"], data["category_name"])
	
	if data["message"].matchn("*update_users*"):
		di.update_users()
		di.discord_message("users updated", data["channel_name"], data["category_name"])
	
	if data["message"].matchn("*update_user_leaderboard*"):
		di.update_user_leaderboard(data)
		di.discord_message("users posted", data["channel_name"], data["category_name"])

func sabotage(data : Dictionary) -> bool:
	#assign team shenanigans
	var t : Dictionary = da.teams
	var u : Dictionary = da.users
	
	var sabatuer_team = data["category_name"]
	var sabatuer_user = data["user_id"]
	var sabotaged : String = ""
	
	var other_teams = t.keys()
	other_teams.shuffle()
	other_teams.erase(sabatuer_team)
	
	for team in other_teams:
		if data["message"].matchn("*%s*" % team) and sabotaged == "":
			sabotaged = team
	
	if sabotaged != "":
		var msg = ""
		var enemy_msg = ""
		
		var attempt_value : float = randf()
		
		if u[sabatuer_user].points > 0:
			u[sabatuer_user].add_points(-1)
			if attempt_value < 0.1:
				# crit fail
				msg = "You really mess up"
				enemy_msg = "%s of %s attempted to sabotage your team but failed!"\
						% [u[sabatuer_user].data["nick"],sabatuer_team]
				t[sabatuer_team].add_points(-1)
			elif attempt_value < 0.2:
				# moderate fail
				msg = "You dont quite make it"
				enemy_msg = "%s attempted to sabotage your team but failed!"\
						% sabatuer_team
			elif attempt_value < 0.3:
				# meh
				msg = "You fail but avoid detection"
			elif attempt_value < 0.5:
				# moderate sucess
				msg = "Imperfect sabotage."
				enemy_msg = "Your team was sabotaged by %s" % sabatuer_team
				t[sabotaged].add_points(-1)
			elif attempt_value < 0.75:
				# moderate sucess
				msg = "Sabotage succesful"
				t[sabotaged].add_points(-1)
				enemy_msg = "Your team was sabotaged"
			elif attempt_value < 0.95:
				# crit succed
				msg = "Sabotage very succesful."
				t[sabotaged].add_points(-1)
				u[sabatuer_user].add_points(1)
			else:
				#extreme sucess
				msg = "Perfect sabotage"
				t[sabotaged].add_points(-1)
				t[sabatuer_team].add_points(1)
				u[sabatuer_user].add_points(1)
		else:
			msg = "You do not have enough personal points to attempt this."
		
		if msg != "":
			ws.send_data({
				"type" : "message",
				"channel_name" : data["channel_name"],
				"category_name": data["category_name"],
				"message" : msg
			})
		if enemy_msg != "":
			ws.send_data({
				"type" : "message",
				"channel_name" : "team-chat",
				"category_name": sabotaged,
				"message" : enemy_msg
			})
		
		da.users = u
		da.teams = t
	
	return sabotaged == ""

func try_spy(data, team):
	if spy_cooldown:
		var face = [">_>", "<_<", "o_0", "0_o", ":O"]
		face.shuffle()
		face = face.front()
		var culprit = "\nIt was: " + data["category_name"] if randf() < 0.1 else ""
		var reply = {
			"type" : "message",
			"channel_name" : "team-chat",
			"category_name": team,
			"message" : "Another team mentioned this team %s" % face + culprit
		}
		ws.send_data(reply)
		spy_cooldown = false
		yield(get_tree().create_timer(300), "timeout")
		spy_cooldown = true
