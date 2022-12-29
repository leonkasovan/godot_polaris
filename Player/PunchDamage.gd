extends "res://Common/Projectile.gd"
const Impact = preload("res://Effects/PunchImpact.tscn")

var hitEnemies = []

func _ready():
	yield (get_tree().create_timer(0.2), "timeout")
	queue_free()

func _process(_delta):
	pass

func _on_VisibilityNotifier2D_viewport_exited(viewport):
	pass


func _on_HitBox_body_entered(body):
	if body.has_method("destroy"):
		body.destroy()
		var impact = Utils.instanceScene(Impact, body.global_position)
		impact.rotation_degrees = rand_range(0, 360)
		Utils.slowTimePulse(0.1, 0.4)


func _on_HitBox_area_entered(_area):
	if not _area in hitEnemies:
		hitEnemies.append(_area)
		var parent = _area.get_parent()
		var impact = Utils.instanceScene(Impact, parent.center.global_position)
		impact.rotation_degrees = rand_range(0, 360)
		if hitEnemies.size() > 0:
			Events.emit_signal("screenShake", 3, 0.6, 60, 3)
			Utils.slowTimePulse(0.1, 0.4)
