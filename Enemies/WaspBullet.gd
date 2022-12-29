extends "res://Common/Projectile.gd"

func _ready():
	pass
	
func formDone():
	$AnimationPlayer.play("Animate")
