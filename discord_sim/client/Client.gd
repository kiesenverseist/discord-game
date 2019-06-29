extends Node

func _ready():
	var up = UPNP.new()
	printt(up.discover(), up.get_device_count())
	print(up.get_device(0).igd_status)
#	var gate = up.get_gateway()
#	print(gate.is_valid_gateway())
	print(up.add_port_mapping(8181, 8181, "discord-game"))
	print(up.query_external_address())
