extends Node
class_name WSRequest

var req_data
var ans_data

signal request_complete

func _init(id,data):
	name = str(id)
	req_data = data

func _ready():
	get_parent().connect("answer", self, "on_answer")

func complete_request(data):
	ans_data = data
	emit_signal("request_complete")

func complete():
	queue_free()

func on_answer(data):
	if str(data["id"]) == name:
		complete_request(data)
