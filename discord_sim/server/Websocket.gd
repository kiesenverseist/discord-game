extends Node

var client = WebSocketClient.new()
var error_count = 0

var message_queue = []

signal user_joined(data)
signal message_recieved(data)

func _ready():
	client.connect("data_received", self, "data_recieved")
	client.connect("connection_established", self, "connection_established")
	client.connect("connection_error", self, "connection_error")
	connect_to_ws()
	keep_alive()

func connect_to_ws():
	print("attempting to connect to websocket")
	client.connect_to_url("ws://kiesen.australiaeast.cloudapp.azure.com:8080")

#warning-ignore:unused_argument
func _process(delta):
	if client.get_connection_status() == WebSocketClient.CONNECTION_DISCONNECTED:
		if error_count <= 0:
			connection_error()
		return
	
	if not message_queue.empty() and client.get_connection_status() == WebSocketClient.CONNECTION_CONNECTED:
		var data = message_queue.pop_front()
		var msg = JSON.print(data)
		printt(">", msg)
		client.get_peer(1).put_packet(msg.to_utf8())
	client.poll()

master func send_data(data : Dictionary):
	message_queue.append(data)
	
	if client.get_connection_status() == WebSocketClient.CONNECTION_DISCONNECTED:
		printerr("the connection is dead, message stored")

func keep_alive():
	if client.get_connection_status() == WebSocketClient.CONNECTION_CONNECTED:
		send_data({"type":"keep alive"})
	get_tree().create_timer(180).connect("timeout", self, "keep_alive")

func data_recieved():
	var data = client.get_peer(1).get_packet()
	data = (data as PoolByteArray).get_string_from_utf8()
	printt("<", data)
	
	data = JSON.parse(data).result

	match data["type"]:
		"message":
			emit_signal("message_recieved", data)
		"member_join":
			emit_signal("user_joined", data)
		_:
			print("unknown data type")

func connection_established(protocol = "none"):
	print("Connection succesfull. Protocol: %s" % protocol)
	send_data({"type":"message", "message":"Server Connected",
			"channel_name" : "bridge", "category_name" : "Super"})
	error_count = 0

func connection_error():
	print("connection error'd")
	error_count += 1
	if error_count < 50:
		yield(get_tree().create_timer(5), "timeout")
		print("Retrying...")
		connect_to_ws()
	else:
		print("Failed to connect too many times")

func close():
	send_data({"type":"message", "message":"Server Closing",
			"channel_name" : "bridge", "category_name" : "Super"})
	yield(get_tree().create_timer(1), "timeout")
	client.disconnect_from_host(1000,"Server closed")

