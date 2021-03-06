extends Node

onready var ws = $"../../Websocket"
onready var da = $"../../Data"
onready var di = get_parent()
var regex = {
	uwou = RegEx.new()
}

var spy_cooldown : bool = true

func _ready():
	regex.uwou.compile("[uUwWoO0]{3}")

func handle_message(data):
	if data["message"].begins_with("^"):
		admin_command(data)
	
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
			$"../../World/MonsterFactory".try_spawn_uwou()
		
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
		
		match data["channel_name"]:
			"generator":
				#give user point
				var us = da.users
				us[data["user_id"]].add_points(1)
				da.users = us
				
				#assign team shenanigans
				var t = da.teams
				
				var other_teams = ["Yellow", "Blue", "Red", "Green"]
				other_teams.shuffle()
				other_teams.erase(data["category_name"])
				
				var found = false
				
				for team in other_teams:
					if data["message"].matchn("*%s*" % team) and not found:
						found = true
						t[team].add_points(-1)
						var reply = {
							"type" : "message",
							"channel_name" : data["channel_name"],
							"category_name": data["category_name"],
							"message" : "Sabotage of %s successful" % team
						}
						ws.send_data(reply)
				
				if not found:
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
				
				#for when a team surpasses 100
				if t[data["category_name"]].points >= 100 and t[data["category_name"]].points <= 101 :
					var reply = {
						"type" : "message",
						"channel_name" : "announcements",
						"category_name": "Super",
						"message" : "Congradulations to %s for reaching 100 points!\nhttps://www.youtube.com/watch?v=1Bix44C1EzY" % data["category_name"]
					}
					ws.send_data(reply)

				da.teams = t
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
				
				var other_teams = ["Yellow", "Blue", "Red", "Green"]
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
	
	else:
		var reply_dm = {}
		reply_dm["type"] = "message"
		reply_dm["channel_id"] = data["channel_id"]
		reply_dm["message"] = "Plox noe dm ;-;"
		ws.send_data(reply_dm)

func admin_command(data):
	if data["user_id"] != "183363112882274305":
		return
	
	if data["message"].matchn("*update_leaderboard*"):
		di.update_leaderboard()
	
	if data["message"].matchn("*update_users*"):
		di.update_users()
	
	if data["message"].matchn("*update_user_leaderboard*"):
		di.update_user_leaderboard(data)

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
