extends Node

var server = NetworkedMultiplayerENet.new()

var all_clients = {}
var player_clients = {}
var remote_servers = {}

func _ready():
	server.create_server(8081, 100)
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
	remote_servers[id] = id
	for i in remote_servers:
		rset_id(i, "remote_servers", remote_servers)
	$Data.set_teams()
	$Data.set_users()

remote func player_client_setup(id):
	print("player connected", id)
	player_clients[id] = id
	for i in player_clients:
		rset_id(i, "player_clients", player_clients)
