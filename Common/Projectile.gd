extends KinematicBody2D
var BulletDisappearEffect = preload("res://Effects/BulletDisappearEffect.tscn")
var BulletHitEffect = preload("res://Effects/BulletHitEffect.tscn")

export (Resource) var wallDestroyObj = null
export (Resource) var hitDestroyObj = null
export (bool) var inheritModulate = true
export (bool) var rotateOn = false
var velo = Vector2()
var reflected = false

onready var hitbox = $HitBox

func _process(delta):
	position += velo * delta
	rotation = velo.angle()


func _on_VisibilityNotifier2D_viewport_exited(viewport):
	queue_free()


func _on_HitBox_body_entered(_body):
	if wallDestroyObj != null:
		var effect = Utils.instanceScene(wallDestroyObj, global_position)
		if rotateOn:
			effect.rotation_degrees = rand_range(0, 360)
		if inheritModulate:
			effect.modulate = modulate
	queue_free()


func _on_HitBox_area_entered(_area):
	if hitDestroyObj != null:
		var effect = Utils.instanceScene(hitDestroyObj, global_position)
		if rotateOn:
			effect.rotation_degrees = rand_range(0, 360)
		if inheritModulate:
			effect.modulate = modulate
	queue_free()
	
