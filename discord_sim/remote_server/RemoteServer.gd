extends Node

var remote_server = NetworkedMultiplayerENet.new()
var self_id

func _ready():
	remote_server.create_client("localhost", 8181)#"192.168.8.110", 8181)
	get_tree().network_peer = remote_server
	self_id = get_tree().get_network_unique_id()
	
	get_tree().network_peer.connect("connection_succeeded", self, "server_connected")
	get_tree().network_peer.connect("connection_failed", self, "server_failed")
	get_tree().network_peer.connect("server_disconnected", self, "server_disconnected")

func server_connected():
	set_network_master(self_id, true)
	for node in [$WebSocket, $Data, $Discord]:
		node.set_network_master(1)
	
	print("connected to server")
	rpc_id(1, "remote_server_setup", self_id)

func server_failed():
	print("could not connect to server")

func server_disconnected():
	print("server disconnected")
