extends Node2D

onready var room:String = get_tree().current_scene.filename
const distort = preload("res://Effects/DistortionEffect.tscn")

func _ready():

	Global.connect("staminaChanged", self, "restoreStamina")
	call_deferred("save")
	
func save():
	Global.lastRoom = room
	Global.saveGame()

func _process(_delta):
	$Particles2D.rotation_degrees += 1

func _on_ShowTimer_timeout():
	$CanvasLayer / Label.visible = true
	SFX.play("SavePointHum")
	Global.health = Global.maxHealth
	Global.stamina = Global.maxStamina
	Global.healthAlly = Global.maxHealthAlly
	humm()

func createDistortion():
	var effect = Utils.instanceScene(distort, $HyperCube.global_position)
	effect.texture = $HyperCube.texture
	effect.scale = $HyperCube.scale
	effect.hframes = $HyperCube.hframes
	effect.frame = round(rand_range(0, 11))
	effect.velo = Vector2.UP * rand_range(2, 4)
	effect.amplitude = 1
	effect.z_index = z_index - 1
	var rot = deg2rad(rand_range(0, 360))
	effect.velo = effect.velo.rotated(rot)
	
func humm():
	randomize()
	var effect = Utils.instanceScene(distort, $HyperCube.global_position)
	effect.texture = $HyperCube.texture
	effect.scale = $HyperCube.scale
	effect.hframes = $HyperCube.hframes
	effect.frame = round(rand_range(0, 11))
	effect.amplitude = 0.5
	effect.freq = 2
	effect.z_index = z_index + 1
	var rot = deg2rad(rand_range(0, 360))
	effect.velo = effect.velo.rotated(rot)
	$Tween.interpolate_property(effect, "scale", effect.scale, Vector2(1, 1), 2)
	$Tween.start()
	
	var player = MainInstances.Player
	var peffect = Utils.instanceScene(distort, player.sprite.global_position)
	peffect.texture = player.sprite.texture
	peffect.scale = Vector2(1.5, 1.5) * player.sprite.scale
	peffect.hframes = player.sprite.hframes
	peffect.frame = player.sprite.frame
	peffect.velo = Vector2.UP * rand_range(2, 4)
	peffect.amplitude = 0.05
	peffect.freq = 2
	peffect.z_index = player.z_index
	
	if MainInstances.Ally != null:
		var ally = MainInstances.Ally
		var aeffect = Utils.instanceScene(distort, ally.sprite.global_position)
		aeffect.texture = ally.sprite.texture
		aeffect.scale = Vector2(1.5, 1.5) * ally.sprite.scale
		aeffect.hframes = ally.sprite.hframes
		aeffect.frame = ally.sprite.frame
		aeffect.velo = Vector2.UP * rand_range(2, 4)
		aeffect.amplitude = 0.05
		aeffect.freq = 2
		aeffect.z_index = ally.z_index
	
func restoreStamina(_val):
	if Global.stamina < Global.maxStamina:
		yield (get_tree().create_timer(1.5), "timeout")
		
		if Global.stamina < Global.maxStamina:
			Global.stamina = Global.maxStamina
			SFX.play("SavePointHum")
			humm()
