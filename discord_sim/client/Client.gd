extends Node

var client = NetworkedMultiplayerENet.new()
var self_id
var user
var token
remote var players : Dictionary = {}

onready var player_client_pk = preload("res://common/player/PlayerClient.tscn")
onready var player_puppet_pk = preload("res://common/player/PlayerPuppet.tscn")

func _ready():
	client.create_client("kiesen.australiaeast.cloudapp.azure.com", 8082)
	get_tree().network_peer = client
	self_id = get_tree().get_network_unique_id()
	
	get_tree().network_peer.connect("connection_succeeded", self, "server_connected")
	get_tree().network_peer.connect("connection_failed", self, "server_failed")
	get_tree().network_peer.connect("server_disconnected", self, "server_disconnected")
	get_tree().network_peer.connect("peer_disconnected", self, "player_disconnected")
	
	set_network_master(1)

func server_connected():
	set_network_master(self_id, true)
	print("connected to server")

func _on_Token_text_entered(new_text):
	token = int(new_text)
	rpc_id(1, "player_setup", self_id, token)

remote func initialise_player(id, u):
	print("player " + str(id) + " registered")
	if int(id) == self_id:
		print("succesfully registered")
		user = u
		$GUI/Token.hide()
		$World.connected()
		
		var p = player_client_pk.instance()
		p.name = str(id)
		$World/Players.add_child(p, true)	
			
		for p in players:
			if p != id:
				initialise_player(int(players[p]["id"]), players[p]["user"])
	
	else:
		var p = player_puppet_pk.instance()
		p.name = str(id)
		$World/Players.add_child(p, true)

func player_disconnected(id):
	get_node("World/Players/%s" % str(id)).queue_free()

func server_failed():
	print("could not connect to server")

func server_disconnected():
	print("server disconnected")
