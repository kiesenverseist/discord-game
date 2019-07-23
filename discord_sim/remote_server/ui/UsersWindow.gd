extends WindowDialog

onready var da = $"../../Data"
onready var IL = $HSplitContainer/ItemList
onready var user_disp = preload("res://remote_server/ui/UserEdit.tscn")

func _ready():
	da.connect("users_updated", self, "update_user_list")

func update_user_list():
	IL.clear()
	var u = da.users
	var i = 0
	for user in u:
		IL.add_item(u[user].data["user_name"])
		IL.set_item_tooltip(i, u[user].data["id"])
		IL.set_item_metadata(i, u[user].data["id"])
		i += 1

func display_user(id):
	for c in $HSplitContainer/Info.get_children():
		c.queue_free()
	
	var u = da.users[id]
	
	var ue = user_disp.instance()
	ue.user = u
	ue.da = da
	$HSplitContainer/Info.add_child(ue)

func _on_ItemList_item_activated(index):
	var id = IL.get_item_metadata(index)
	display_user(id)
