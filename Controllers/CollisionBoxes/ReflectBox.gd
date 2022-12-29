extends Area2D

var Effect = preload("res://Effects/ReflectEffect.tscn")

export  var newMask = 2 + 4
export  var speedMultiplier:float = 1.0
export  var damageMultiplier:float = 1.0
export  var angleVariation = 5
export (Color) var modulateColor = Color("18aeff")


func _ready():
	pass





func _on_ReflectBox_body_entered(bullet):
	if not bullet.reflected:
		var effect = Utils.instanceScene(Effect, bullet.global_position)
		effect.rotation_degrees = rand_range(0, 360)
		effect.z_index = z_index + 1
		bullet.reflected = true
		bullet.velo = bullet.velo.rotated(deg2rad(180) + deg2rad(rand_range( - angleVariation, angleVariation))) * speedMultiplier
		bullet.hitbox.damage *= damageMultiplier
		bullet.hitbox.collision_mask = newMask
		bullet.modulate = modulateColor
		SFX.play("BulletReflect", rand_range(0.9, 1.1))
