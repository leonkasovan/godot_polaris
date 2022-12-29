extends "res://Enemies/Enemy.gd"

export  var acceleration = 100

enum STATE{
	HANG, 
	FALL, 
	CHASE
}

var state = STATE.HANG
signal died

func _ready():
	pass

func _physics_process(delta):
	match state:
		STATE.HANG:
			pass
		STATE.FALL:
			$AnimationPlayer.play("Fall")
			Utils.facePlayer(self, $Sprite)
			velo.y += 5
			velo = move_and_slide(velo)

		STATE.CHASE:
			$AnimationPlayer.play("Fly")
			var player = MainInstances.Player
			if player != null:
				chasePlayer(player, delta)
			Utils.facePlayer(self, $Sprite)
		
func chasePlayer(player, delta):
	var direction = ((player.global_position - Vector2(0, 30)) - global_position).normalized()
	velo += direction * acceleration * delta
	velo = velo.clamped(maxSpeed)
	velo = move_and_slide(velo)
	
func alert():
	if state == STATE.HANG:
		state = STATE.FALL
		$FallTimer.start()
		SFX.play("BatAlert", rand_range(0.9, 1.1))

func _on_PlayerDetector_body_entered(_body):
	alert()

func _on_FallTimer_timeout():
	state = STATE.CHASE
	
func _on_HurtBox_hit(damage, _knockback, _hitboxPosn):
	stats.health -= damage
	flash()
	SFX.play("EnemyHit", rand_range(0.8, 1.1))
	alert()
	
func _on_EnemyStats_enemyDied():
	queue_free()
	createDeathExplosion()
	SFX.play("EnemyDie", rand_range(0.8, 1.1))
	SFX.play("BatDeath", rand_range(0.9, 1.1))
	emit_signal("died")
