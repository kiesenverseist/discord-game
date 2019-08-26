extends Node

var server := NetworkedMultiplayerENet.new()

var players : Dictionary = {}

onready var da = $"../Backend/Data"
onready var player_server_pk = preload("res://common/player/PlayerServer.tscn")

func _ready():
	print("starting playerend server")
	server.create_server(8082, 100)
	custom_multiplayer = MultiplayerAPI.new()
	custom_multiplayer.network_peer = server
	custom_multiplayer.set_root_node(get_parent())
	
	custom_multiplayer.connect("network_peer_connected",self, "client_connected")
	custom_multiplayer.connect("network_peer_disconnected",self, "client_disconnected")
	
	get_tree().connect("node_added", self, "_on_children_changed")
	
	set_network_master(1)
	yield(get_tree(), "idle_frame")
	_on_children_changed(null)

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
	printt("client connected", id)
	players[id] = null

func client_disconnected(id):
	printt("client disconnected", id)
	
	if id in players and players[id] != null:
		players.erase(id)
		get_node("World/Players/%s" % str(id)).queue_free()

remote func player_setup(id, token):
	var u = da.users
	var usr = null
	
	for user in u:
		if u[user].token == int(token):
			usr = user
			break
	
	if usr == null:
		print("token not valid")
		rpc_id(id, "invalid_token")
		return
	
	printt("player connected", id, u[usr].data["user_name"], usr)
	players[id] = {
		"id" : id,
		"user" : usr
	}
	
	initialise_player(id, usr)
	
	for i in players:
		rset_id(i, "players", players)
		rpc_id(i, "initialise_player", id, usr)

func initialise_player(id, u):
	var p = player_server_pk.instance()
	p.name = str(id)
	p.usr_id = u
	$World/Players.add_child(p, true)
