extends "res://Enemies/Enemy.gd"

var ghostEffect = preload("res://Effects/BoneGhostEffect.tscn")
var dustEffect = preload("res://Effects/DustEffect.tscn")
var Bullet = preload("res://Enemies/BoneBullet.tscn")
var lastAttack = - 1
onready var player = MainInstances.Player
signal defeated

enum STATE{
	INIT, 
	IDLE, 
	DASH_ATTACK_PREP, 
	DASH_ATTACK, 
	JUMP_ATTACK_PREP, 
	JUMP_ATTACK, 
	SPIN_ATTACK_PREP, 
	SPIN_ATTACK, 
	DEFEATED, 
	EXIT
}

onready var anim = $AnimationPlayer
onready var spinCollision = $HitBoxSpin / CollisionShape2D
onready var dashCollision = $Sprite / HitBoxDashAttack / CollisionShape2D
onready var reflect = $ReflectBox / CollisionShape2D
onready var hpBar = $EnemyStats / BossHealthMeter / BossHealthMeter
var state = STATE.IDLE
var dashSpd = 800
var dashFriction = 17
var gravity = 500
var jumpHeight = 350
var spinChaseAccel = 11

func _ready():
	set_physics_process(false)

func _physics_process(delta):
	match state:
		STATE.INIT:
			pass
		STATE.IDLE:
			facePlayer()
			velo.x = 0
			move(delta)
		STATE.DASH_ATTACK_PREP:
			move(delta)
			facePlayer()
		STATE.DASH_ATTACK:
			move(delta)
			checkReverse()
			velo.x = move_toward(velo.x, 0, dashFriction)
			if velo.x < 200 and velo.x > - 200 and anim.current_animation != "DashAttackDone":
				anim.play("DashAttackDone")
				dashCollision.disabled = true
				reflect.disabled = true
		STATE.JUMP_ATTACK_PREP:
			move(delta)
			facePlayer()
		STATE.JUMP_ATTACK:
			move(delta)
			if is_on_floor():
				idle()
		STATE.SPIN_ATTACK_PREP:
			move(delta)
		STATE.SPIN_ATTACK:
			move(delta)
			spinChase()
			facePlayer()
		STATE.DEFEATED:
			facePlayer()
			velo.x = 0
			move(delta)
			if is_on_floor():
				anim.play("Defeated")
		STATE.EXIT:
			move(delta)
			velo.y = - 500
			anim.play("JumpAttackPrep")
			
func init():
	$InitTimer.start()
	hpBar.visible = true
	
func _on_InitTimer_timeout():
	if stats.health < stats.maxHealth:
		stats.health += 2
		SFX.play("BossHpFill")
	else :
		$InitTimer.stop()
		yield (get_tree().create_timer(1.0), "timeout")
		prepDashAttack()
		player.state = player.STATE.MOVE
		Music.play("SuperNova", 0)
		
func chooseAttack():
	var result = getNextAttack()
	while lastAttack == result:
		result = getNextAttack()
	if result == 0:
		prepDashAttack()
	elif result == 1:
		prepJumpAttack()
	else :
		prepSpinAttack()
	lastAttack = result

func getNextAttack():
	var result
	var chance = rand_range(0.0, 100.0)
	if chance < 35:
		result = 0
	elif chance < 70:
		result = 1
	else :
		result = 2
	return result
	
func idle():
	state = STATE.IDLE
	anim.play("Idle")
	$AttackTimer.start()
	
func prepDashAttack():
	state = STATE.DASH_ATTACK_PREP
	anim.play("DashAttackPrep")
	
func executeDashAttack():
	dashCollision.disabled = false
	state = STATE.DASH_ATTACK
	anim.play("DashAttack")
	velo.x = sprite.scale.x * dashSpd
	SFX.play("BoneBossDash", 1.5)
	reflect.disabled = false
	
func prepJumpAttack():
	state = STATE.JUMP_ATTACK_PREP
	anim.play("JumpAttackPrep")
	velo.y = - jumpHeight
	velo.x = sprite.scale.x * rand_range(150, 250)
	$JumpAttackTimer.start()
	
func executeJumpAttack():
	for i in 3:
		var dir = player.center.global_position - global_position
		var bullet = Utils.instanceScene(Bullet, $Sprite / Center.global_position + Vector2(sprite.scale.x * 6, 6))
		bullet.velo = dir.normalized().rotated(deg2rad(18 * i - 18)) * 400
	state = STATE.JUMP_ATTACK
	anim.play("JumpAttackThrow")
	SFX.play("BoneBossJumpAttack", 1.5)
	velo.y = - 75
	
func jumpAttackDone():
	anim.play("JumpAttackDone")
	
func prepSpinAttack():
	anim.play("SpinAttackPrep")
	
func executeSpinAttack():
	reflect.disabled = false
	spinCollision.disabled = false
	state = STATE.SPIN_ATTACK
	anim.play("SpinAttack")
	$SpinAttackTimer.start()
	SFX.play("BoneBossSpin", 1.1)
	
func _on_SpinAttackTimer_timeout():
	anim.play("DashAttackDone")
	state = STATE.DASH_ATTACK
	spinCollision.disabled = true
	reflect.disabled = true
	
func spinChase():
	if player.global_position.x > global_position.x:
		velo.x += spinChaseAccel
	else :
		velo.x -= spinChaseAccel
	velo.x = clamp(velo.x, - 300, 300)
	
func facePlayer():
	if player.global_position.x > global_position.x:
		$Sprite.scale.x = 1
		$LightSprite.scale.x = 1
	else :
		sprite.scale.x = - 1
		$LightSprite.scale.x = - 1

func applyGravity(delta):
	if not is_on_floor():
		velo.y += gravity * delta

func move(delta):
	applyGravity(delta)

	move_and_slide(velo, Vector2.UP)

func checkReverse():
	if $Sprite / WallCast.is_colliding():
		velo.x *= - 1
		sprite.scale.x *= - 1
		$LightSprite.scale.x *= - 1

func createGhostEffect():
	var ghost = Utils.instanceScene(ghostEffect, sprite.global_position)
	ghost.texture = sprite.texture
	ghost.hframes = sprite.hframes
	ghost.frame = sprite.frame
	ghost.scale = sprite.scale
	
func createDustEffect():
	Utils.instanceScene(dustEffect, global_position + Vector2(rand_range( - 4, 4), 0))

func _on_EnemyStats_enemyDied():
	Utils.slowTimePulse(0.1, 0.5)
	state = STATE.DEFEATED
	if not is_on_floor():
		anim.play("JumpAttackDone")
	$ReflectBox / CollisionShape2D.set_deferred("disabled", true)
	$HitBoxSpin / CollisionShape2D.set_deferred("disabled", true)
	$Sprite / HitBoxDashAttack / CollisionShape2D.set_deferred("disabled", true)
	$HitBox / CollisionShape2D.set_deferred("disabled", true)
	$HurtBox / CollisionShape2D.set_deferred("disabled", true)
	$AttackTimer.stop()
	$JumpAttackTimer.stop()
	$SpinAttackTimer.stop()
	$FlashTimer.stop()
	createDeathExplosion()
	SFX.play("EnemyDie", rand_range(0.8, 1.1))
	Music.stop(0)
	SFX.play("Victory")
	emit_signal("defeated")
	yield (get_tree().create_timer(0.1), "timeout")
	Utils.playerFace(self)
	player.state = player.STATE.NOCONTROL
	
func exitStage():
	state = STATE.EXIT
	SFX.play("BoneBossDash", 1.5)
	yield (get_tree().create_timer(1.5), "timeout")
	queue_free()
