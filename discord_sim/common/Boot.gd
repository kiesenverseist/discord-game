extends Node

var state : int

var ip
var port

func _ready():
	
	if OS.has_feature("Server"):
		get_tree().change_scene("res://server/Server.tscn")
	if OS.has_feature("client"):
		return
		get_tree().change_scene("res://client/client.tscn")

func _on_menu_item_selected(index : int):
	state = index
	match state:
		0 :
			$VBoxContainer/Port.show()
		1, 2 :
			$VBoxContainer/Port.show()
			$VBoxContainer/IP.show()
		_ :
			pass
	
	$VBoxContainer/Back.show()
	$VBoxContainer/Accept.show()
	$VBoxContainer/Menu.hide()

func _on_Back_pressed():
	for child in $VBoxContainer.get_children():
		child.hide()
	$VBoxContainer/Menu.show()

func _on_Accept_pressed():
	match state:
		0 :
			get_tree().change_scene("res://server/Server.tscn")
		1 :
			get_tree().change_scene("res://remote_server/RemoteServer.tscn")
		2 :
			pass
		_ :
			pass

func _on_IP_changed(new_text : String):
	if new_text.empty():
		$VBoxContainer/IP/ColorRect.hide()
	else:
		$VBoxContainer/IP/ColorRect.show()
		if new_text.is_valid_ip_address():
			$VBoxContainer/IP/ColorRect.color = Color(0,1,0)
			$VBoxContainer/IP/ColorRect.hint_tooltip = "adress is valid"
		else:
			$VBoxContainer/IP/ColorRect.color = Color(1,0,0)
			$VBoxContainer/IP/ColorRect.hint_tooltip = "invalid adress"

func _on_Port_changed(new_text : String):
	if new_text.empty():
		$VBoxContainer/Port/ColorRect.hide()
	else:
		$VBoxContainer/Port/ColorRect.show()
		if new_text.is_valid_integer():
			if int(new_text) < 65535 and int(new_text) > 1023:
				$VBoxContainer/Port/ColorRect.color = Color(0,1,0)
				$VBoxContainer/Port/ColorRect.hint_tooltip = "port given is valid"
			else:
				$VBoxContainer/Port/ColorRect.color = Color(1,1,0)
				$VBoxContainer/Port/ColorRect.hint_tooltip = "port given is out of range"
		else:
			$VBoxContainer/Port/ColorRect.color = Color(1,0,0)
			$VBoxContainer/Port/ColorRect.hint_tooltip = "port given is NAN"
