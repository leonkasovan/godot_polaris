extends Spatial

onready var shakeTimer = $Camera / ShakeTimer
onready var newShake = $Camera / NewShake

func _process(_delta):
	$PlanetBG.rotation_degrees.y -= 0.02
	
func playStart():
	$Tween.interpolate_property($Blur.get_material(), "shader_param/blur_amount", 1, 0, 1)
	$Tween.start()
	yield (get_tree().create_timer(2.0), "timeout")
	shake()
	SFX.play("ShipPass")
	$Ship.set_physics_process(true)
	yield (get_tree().create_timer(0.2), "timeout")
	$Ship / Particles.emitting = true
	yield (get_tree().create_timer(3.0), "timeout")
	$StartMenu.fadeToStart()
	$Tween.interpolate_property($Camera, "rotation_degrees", $Camera.rotation_degrees, $Camera.rotation_degrees + Vector3(10, 0, 0), 3, Tween.TRANS_SINE, Tween.EASE_IN)
	$Tween.start()
	
func shake():
	shakeTimer.start()
	newShake.start()

func _on_NewShake_timeout():
	if shakeTimer.time_left > 0:
		$Tween.interpolate_property($Camera, "h_offset", 0, rand_range( - 0.1, 0.1), 0.02)
		$Tween.interpolate_property($Camera, "v_offset", 0, rand_range( - 0.1, 0.1), 0.02)
		$Tween.start()
	else :
		$Tween.interpolate_property($Camera, "h_offset", $Camera.h_offset, 0, 0.1)
		$Tween.interpolate_property($Camera, "v_offset", $Camera.v_offset, 0, 0.1)
		$Tween.start()
