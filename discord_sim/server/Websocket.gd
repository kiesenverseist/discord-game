extends Node

var client = WebSocketClient.new()

signal user_joined(data)
signal message_recieved(data)

func _ready():
	client.connect_to_url("ws://kiesen.australiaeast.cloudapp.azure.com:8080")
	client.connect("data_received", self, "data_recieved")
	client.connect("connection_established", self, "connection_established")
	client.connect("connection_error", self, "connection_error")
			

#warning-ignore:unused_argument
func _process(delta):
	if client.get_connection_status() == WebSocketClient.CONNECTION_DISCONNECTED:
		return
	client.poll()

master func send_data(data : Dictionary):
	var msg = JSON.print(data)
	printt(">", msg)
	client.get_peer(1).put_packet(msg.to_utf8())

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
	print("Connection succesfull: %s" % protocol)
	send_data({"type":"message", "message":"Server Connected",
			"channel_id" : "566610532786765854"})

func connection_error():
	print("connection error'd")

func close():
	send_data({"type":"message", "message":"Server Closed",
			"channel_id" : "566610532786765854"})
	client.disconnect_from_host(1000,"Server closed")

