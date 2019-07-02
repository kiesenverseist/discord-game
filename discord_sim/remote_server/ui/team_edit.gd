extends VBoxContainer

var base

func _ready():
	yield(get_tree(), "idle_frame")
	$HBoxContainer/Button.connect("pressed", base, "_on_EditPoints_pressed")
	$TeamChat.connect("toggled", base, "_on_TeamChat_toggled")
	$VoiceChat.connect("toggled", base, "_on_VoiceChat_toggled")
