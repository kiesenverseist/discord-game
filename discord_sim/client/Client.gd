extends Node

var client = NetworkedMultiplayerENet.new()
var self_id
remote var player_clients : Dictionary = {}
func _ready():
	client.create_client("localhost", 8082)#"kiesen.australiaeast.cloudapp.azure.com", 8082)
	get_tree().network_peer = client
	self_id = get_tree().get_network_unique_id()
	
	get_tree().network_peer.connect("connection_succeeded", self, "server_connected")
	get_tree().network_peer.connect("connection_failed", self, "server_failed")
	get_tree().network_peer.connect("server_disconnected", self, "server_disconnected")

func server_connected():
	set_network_master(self_id, true)
	
	print("connected to server")
	rpc_id(1, "player_setup", self_id)

func server_failed():
	print("could not connect to server")

func server_disconnected():
	print("server disconnected")
