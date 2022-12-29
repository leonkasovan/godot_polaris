extends Area2D

export (int) var damage = 1
export (float) var knockback = 0

var ignore = null
signal hit

func _ready():
	var parent = get_parent()
	if parent.get("hitBoxIgnore") != null:
		var path = parent.get("hitBoxIgnore")
		ignore = parent.get_node(path)

func _on_HitBox_area_entered(hurtbox):
	if hurtbox == ignore:
		return 
	hurtbox.emit_signal("hit", damage, knockback, self.global_position)
	emit_signal("hit")
