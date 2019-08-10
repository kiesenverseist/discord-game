extends Node

var server := NetworkedMultiplayerENet.new()

var players : Dictionary = {}

onready var da = $"../Backend/Data"

func _ready():
	print("starting playerend server")
	server.create_server(8082, 100)
	custom_multiplayer = MultiplayerAPI.new()
	custom_multiplayer.network_peer = server
	custom_multiplayer.set_root_node(get_parent())
	
	custom_multiplayer.connect("network_peer_connected",self, "client_connected")
	custom_multiplayer.connect("network_peer_disconnected",self, "client_disconnected")
	
	get_tree().connect("node_added", self, "_on_children_changed")

func _process(delta):
	custom_multiplayer.poll()

func _on_children_changed(node):
	var all_children = [self]
	for c in all_children:
		for child in c.get_children():
			all_children.append(child)
	
	for c in all_children:
		(c as Node).custom_multiplayer = custom_multiplayer

func client_connected(id):
	print("client connected", id)
	players[id] = null

func client_disconnected(id):
	print("client disconnected", id)
	
	if id in players:
		players.erase(id)

remote func player_setup(id, token):
	var u = da.users
	var usr = null
	
	for user in u:
		if u[user].token == int(token):
			usr = user
			break
	
	if usr == null:
		return
	
	printt("player connected", id, u[usr].data["user_name"], usr)
	players[id] = id
	for i in players:
		rset_id(i, "players", players)

sync func initialise_player(id, u):
	pass
