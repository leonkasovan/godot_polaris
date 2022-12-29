extends "res://Enemies/Enemy.gd"

var Bullet = load("res://Enemies/AmgusLotusBullet.tscn")
export  var BulletWaitTime = 3.0
export  var initialWaitTime = 2.0
var active = false


func _ready():
	$BulletTimer.wait_time = initialWaitTime
	$BulletTimer.start()
	
func _on_BulletTimer_timeout():
	$AnimationPlayer.play("Attack")
	$BulletTimer.wait_time = BulletWaitTime
	$BulletTimer.start()
	
func fireBullets():
	if not active:
		return 
	for i in 5:
		var dir = - (i * 22.5) - 45
		dir = deg2rad(dir)
		var bullet = Utils.instanceScene(Bullet, $Muzzle.global_position)
		bullet.velo = Vector2(100, 0).rotated(dir + global_rotation)
	SFX.play("AmgusLotusShoot", rand_range(0.9, 1.1))

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Attack":
		$AnimationPlayer.play("Idle")
		
func _on_EnemyStats_enemyDied():
	queue_free()
	createDeathExplosion()
	SFX.play("EnemyDie", rand_range(0.8, 1.1))
	SFX.play("AmgusLotusDeath", rand_range(0.9, 1.1))

func _on_VisibilityNotifier2D_screen_entered():
	active = true

func _on_VisibilityNotifier2D_screen_exited():
	active = false
