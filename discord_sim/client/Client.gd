extends Node

var client = NetworkedMultiplayerENet.new()
var self_id
var user
var token
var user_data : Dictionary = {}
var team : Team = Team.new("null")
remote var players : Dictionary = {}

onready var player_client_pk = preload("res://common/player/PlayerClient.tscn")
onready var player_puppet_pk = preload("res://common/player/PlayerPuppet.tscn")

func connect_to_server():
	$GUI/Status.text = "Connecting"
	client.create_client("kiesen.australiaeast.cloudapp.azure.com", 8082)
	get_tree().network_peer = client
	self_id = get_tree().get_network_unique_id()
	
	get_tree().network_peer.connect("connection_succeeded", self, "server_connected")
	get_tree().network_peer.connect("connection_failed", self, "server_failed")
	get_tree().network_peer.connect("server_disconnected", self, "server_disconnected")
	get_tree().network_peer.connect("peer_disconnected", self, "player_disconnected")
	
	set_network_master(1)

func server_connected():
	$GUI/Status.text = "Connected, registering"
	set_network_master(self_id, true)
	print("connected to server")
	rpc_id(1, "player_setup", self_id, token)

func _on_Token_text_entered(new_text):
	if multiplayer.network_peer == null:
		token = int(new_text)
		connect_to_server()

remote func initialise_player(id, u):
	print("player " + str(id) + " registered")
	if int(id) == self_id:
		$GUI/Status.text = "registered"
		get_tree().create_timer(5).connect("timeout", $GUI/Status, "queue_free")
		print("succesfully registered")
		user = u
		$GUI/Token.hide()
		$World.connected()
		
		var p = player_client_pk.instance()
		p.name = str(id)
		$World/Players.add_child(p, true)
		
		p.connect("user_data_set", self, "user_data_updated")
		p.connect("team_data_set", self, "team_data_updated")
		
		for p in players:
			if p != id:
				initialise_player(int(players[p]["id"]), players[p]["user"])
	
	else:
		var p = player_puppet_pk.instance()
		p.name = str(id)
		$World/Players.add_child(p, true)

remote func invalid_token():
	get_tree().network_peer = null
	$GUI/Status.text = "Invalid token, disconnected."

func user_data_set(dat):
	user_data = dat
	$GUI.update_gui()

func team_data_set(dat):
	team.set_all(dat)
	$GUI.update_gui()

func player_disconnected(id):
	var pn = get_node("World/Players/%s" % str(id))
	if pn:
		pn.queue_free()

func server_failed():
	print("could not connect to server")

func server_disconnected():
	print("server disconnected")
