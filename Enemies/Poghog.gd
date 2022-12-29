extends "res://Enemies/Enemy.gd"

export (int) var jumpHeight = - 150
export (int) var gravity = 500
export (int) var deagroDist = 200

var player

enum STATE{
	IDLE, 
	MOVE, 
	CHARGE, 
	DETECT
}

var state = STATE.IDLE

func _ready():
	randomize()

func _physics_process(delta):
	match state:
		STATE.IDLE:
			$AnimationPlayer.playback_speed = 1
			$AnimationPlayer.play("Idle")
			checkForPlayer()
			applyGravity(delta)
			velo.x = 0
			velo = move_and_slide(velo, Vector2.UP)
		STATE.MOVE:
			$AnimationPlayer.playback_speed = 0.5
			$AnimationPlayer.play("Walk")
			velo.x = $Sprite.scale.x * maxSpeed
			velo = move_and_slide(velo, Vector2.UP)
			if $Sprite / FloorCast.is_colliding() == false:
				$Sprite.scale.x *= - 1
			if $Sprite / WallCast.is_colliding():
				$Sprite.scale.x *= - 1
			checkForPlayer()
			applyGravity(delta)
		STATE.CHARGE:
			$AnimationPlayer.playback_speed = 1
			$AnimationPlayer.play("Walk")
			velo.x = $Sprite.scale.x * maxSpeed * 2
			velo = move_and_slide(velo, Vector2.UP)
			if $Sprite / FloorCast.is_colliding() == false or $Sprite / WallCast.is_colliding():
				$Sprite.scale.x *= - 1
			applyGravity(delta)
		STATE.DETECT:
			$AnimationPlayer.playback_speed = 1
			$AnimationPlayer.play("Idle")
			applyGravity(delta)
			velo.x = 0
			velo = move_and_slide(velo, Vector2.UP)

func checkForPlayer():
	if $Sprite / PlayerCast.is_colliding():
		player = $Sprite / PlayerCast.get_collider()
		SFX.play("PigAlert")
		state = STATE.DETECT
		$StateTimer.stop()
		Utils.emote(self, 0, Vector2(0, - 42))
		$DetectTimer.start()
		
func applyGravity(delta):
	if not is_on_floor():
		velo.y += gravity * delta
	else :
		velo.y = 1

func _on_StateTimer_timeout():
	if state == STATE.IDLE:
		state = STATE.MOVE
		var chance = rand_range(0, 100)
		if chance < 50:
			$Sprite.scale.x *= - 1
	elif state == STATE.MOVE:
		state = STATE.IDLE
	elif state == STATE.CHARGE:
		if global_position.distance_to(player.global_position) > deagroDist:
			state = STATE.IDLE
	$StateTimer.wait_time = rand_range(1, 3)
	$StateTimer.start()

func _on_DetectTimer_timeout():
	state = STATE.CHARGE
	$StateTimer.start()
	
func createDustEffect():
	if state == STATE.CHARGE:
		Utils.instanceScene(load("res://Effects/DustEffect.tscn"), global_position + Vector2(rand_range( - 5, 5), rand_range( - 1, 1)))
		
func _on_HurtBox_hit(damage, _knockback, _hitboxPosn):
	stats.health -= damage
	flash()
	SFX.play("EnemyHit", rand_range(0.8, 1.1))
	if state != STATE.CHARGE:
		Utils.facePlayer(self, $Sprite)
		
func _on_EnemyStats_enemyDied():
	queue_free()
	createDeathExplosion()
	SFX.play("EnemyDie", rand_range(0.8, 1.1))
	SFX.play("PigDeath", rand_range(0.9, 1.1))
