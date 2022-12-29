extends KinematicBody2D

export  var maxSpeed:int = 30
export  var sizeScale:float = 1.0
export (NodePath) var hitBoxIgnore = null
export  var allyIgnore:bool = false
var velo = Vector2()

onready var stats = $EnemyStats
onready var sprite = $Sprite
onready var flashTimer = $FlashTimer
onready var center = $Sprite / Center

export (PackedScene) var ExplodingDust = preload("res://Effects/ExplodingDust.tscn")
export (PackedScene) var SmokeExplode = preload("res://Effects/SmokeExplosion.tscn")



func _on_HurtBox_hit(damage, knockback, hitboxPosn):
	stats.health -= damage
	flash()
	SFX.play("EnemyHit", rand_range(0.8, 1.1))

func _on_EnemyStats_enemyDied():
	queue_free()
	createDeathExplosion()
	SFX.play("EnemyDie", rand_range(0.8, 1.1))
	
func flash():
	sprite.material.set_shader_param("flash_modifier", 1)
	flashTimer.start()
	
func createDeathExplosion():
	randomize()
	if ExplodingDust:
		var scaler = round(5.0 * sizeScale)
		for i in scaler:
			var dust = Utils.instanceScene(ExplodingDust, global_position + Vector2(0, rand_range( - 12, 12)))
			dust.velo = Vector2((70 * sizeScale) * (i - scaler / 2), rand_range(0, - 250 * sizeScale))
			dust.scale.x = sizeScale
			dust.scale.y = sizeScale
	var explode = Utils.instanceScene(SmokeExplode, center.global_position)
	var randscale = [ - 1, 1]
	var xscale = randscale[randi() % randscale.size()]
	explode.scale.x = sizeScale * xscale
	explode.scale.y = sizeScale

func _on_FlashTimer_timeout():
	sprite.material.set_shader_param("flash_modifier", 0)
	

