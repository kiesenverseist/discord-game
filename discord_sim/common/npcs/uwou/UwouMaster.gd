extends "Uwou.gd"

var sub_point = 3
var targets : Array = []

var shoot_cooldown : float = 0.5
var can_shoot : bool = true
signal shoot


func _ready():
	direction = Vector2(1,0).rotated(rand_range(0, 2*PI))

func _process(delta):
	if len(targets)>0:
		var target
		var min_dist = INF
		
		for t in targets:
			var dist = (position - t.position).length()
			if dist < min_dist :
				min_dist = dist
				target = t
		
		var dir = (target.position - position).normalized()
		
		shoot(dir)

func give_point(amount):
	points += amount

func shoot(dir : Vector2) -> void:
	if can_shoot:
		can_shoot = false
		emit_signal("shoot", position, dir)
		yield(get_tree().create_timer(shoot_cooldown), "timeout")
		can_shoot = true

func move():
	direction = direction.rotated(rand_range(-0.1, 0.1))
	if custom_multiplayer != null:
		rpc("move", position, direction)

func _on_PointCountdown_timeout():
	sub_point -= 1
	
	# sorry i also dont understand what i was trying to do here
	
	if sub_point <= 0:
		points += 1
		rset("points", points)
		sub_point = randi()%9 + 1

func _on_Range_body_entered(body):
	if body is preload("res://common/player/player.gd"):
		targets.append(body)
		print("target player added")

func _on_Range_body_exited(body):
	if body in targets:
		targets.erase(body)
		print("target player removed")
