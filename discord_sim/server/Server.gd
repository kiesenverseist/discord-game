extends Node

var server = NetworkedMultiplayerENet.new()

var all_clients = {}
var player_clients = {}
var remote_servers = {}

func _ready():
	server.create_server(8181, 100)
	get_tree().network_peer = server
	
	get_tree().connect("network_peer_connected",self, "client_connected")
	get_tree().connect("network_peer_disconnected",self, "client_disconnected")
	
	for c in [$Websocket, $Data, $Discord]:
		c.set_network_master(1)

func client_connected(id):
	print("client connected", id)
	all_clients[id] = null

func client_disconnected(id):
	print("client disconnected", id)
	all_clients.erase(id)
	
	if id in player_clients:
		player_clients.erase(id)
	
	if id in remote_servers:
		remote_servers.erase(id)

remote func remote_server_setup(id):
	print("remote server connected", id)
	remote_servers[id] = null
	$Data.set_teams()
	$Data.set_users()

remote func player_client_setup(id):
	player_clients[id] = null
