extends GridContainer

var user : User setget set_user
var da

func _ready():
	for c in get_children():
		if c is LineEdit:
			(c as LineEdit).connect("text_entered", self, "property_changed", [c.name])

func set_user(u : User):
	user = u
	$UserName.text = u.data["user_name"]
	$NickName.text = u.data["nick"]
	$ID.text = u.data["id"]
	$Team.text = u.data["team"]
	$Points.text = str(u.data["points"])

func property_changed(value, property):
	var users = da.users
	user = users[user.data["id"]]
	match property:
		"UserName":
			user.data["user_name"] = value
		"Nickname":
			user.data["nick"] = value
		"ID":
			user.data["id"] = value
		"Team":
			user.data["team"] = value
		"Points":
			user.data["points"] = int(value)
		_:
			printerr("unknown property set in useredit", property, value)
	users[user.data["id"]] = user
	set_user(user)
	da.users = users
