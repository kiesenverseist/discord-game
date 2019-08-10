extends Node

var server = NetworkedMultiplayerENet.new()

var remote_servers = {}

func _ready():
	print("starting backend server")
	server.create_server(8081, 3)
	custom_multiplayer = MultiplayerAPI.new()
	custom_multiplayer.network_peer = server
	custom_multiplayer.set_root_node(get_parent())
	
	custom_multiplayer.connect("network_peer_connected",self, "client_connected")
	custom_multiplayer.connect("network_peer_disconnected",self, "client_disconnected")
	
	for c in [$Websocket, $Data, $Discord]:
		c.set_network_master(1)
		c.custom_multiplayer = custom_multiplayer

func _process(delta):
	custom_multiplayer.poll()

func client_connected(id):
	print("client connected", id)
	remote_servers[id] = null

func client_disconnected(id):
	print("client disconnected", id)
	
	if id in remote_servers:
		remote_servers.erase(id)

remote func remote_server_setup(id):
	print("remote server connected", id)
	remote_servers[id] = id
	for i in remote_servers:
		rset_id(i, "remote_servers", remote_servers)
	$Data.set_teams()
	$Data.set_users()
