extends Node

var server = NetworkedMultiplayerENet.new()

var clients = {}
var remote_server

func _ready():
	server.create_server(8181, 100)
	get_tree().network_peer = server
	
	get_tree().connect("network_peer_connected",self, "client_connected")
	get_tree().connect("network_peer_disconnected",self, "client_disconnected")

func client_connected(id):
	clients[id] = null

func client_disconnected(id):
	clients.erase(id)

remote func remote_server_setup(id):
	remote_server = id