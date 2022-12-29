extends KinematicBody2D

var DustEffect = preload("res://Effects/DustEffect.tscn")
var Bullet = preload("res://Allies/WingBullet.tscn")
var hurtEffect = preload("res://Effects/HurtEffect.tscn")
var knockout = preload("res://Effects/KnockedOutEffect.tscn")
onready var gunTimer = $Gun / Timer
onready var anim = $AnimationPlayer
onready var UI = $AllyHealthMeter / AllyHealthMeter

signal revived

enum STATE{
	MOVE, 
	JUMP, 
	EVENT, 
	ATTACK, 
	DIE, 
	NOCONTROL, 
	STANDBY
}
enum COMMAND{
	null, 
	waitMove, 
	jump, 
	stop, 
	event, 
	inputOverride
}

var command = null
var player
export  var velo = Vector2()
var acceleration = 1000
var maxSpeed = 140
var friction = 80
var gravity = 800
var jumpHeight = 300
var maxFallSpd = 250
var snapVector = Vector2()
var inputVector = Vector2()
var justJumped = false
var followDist = 70
var stopDist = 40
var jumpVelo = Vector2()
var stopDir = 0
var currentEvent = null
const SLOPE_STOP_THRESH = 20
export (STATE) var state = STATE.MOVE
export (float) var attackRange = 250
export (Vector2) var overrideInputVector = Vector2()
var gunRotSpeed = 4
var target = null

onready var sprite = $Sprite
onready var EventPlayer = $EventPlayer
onready var scan = $EnemyScanner

func _ready():

	MainInstances.connect("playerValChanged", self, "playerValChanged")
	MainInstances.Ally = self
	playerValChanged(MainInstances.Player)
	global_position = player.global_position - Vector2(player.sprite.scale.x * 16, 0)
	$LandEventTimer.start()
	
func _exit_tree():
	MainInstances.Ally = null
	
func _process(_delta):
	pass
		
		
func _physics_process(delta):
	match state:
		STATE.MOVE:
			inputVector = getInputVector()
			applyHorizontalForce(delta)
			applyFriction()
			updateSnapVector()
			applyGravity(delta)
			updateAnimation()
			facePlayer()
			checkForJump()
			checkForEvent()
			checkForDie()
			scanForEnemies()
			move()
		STATE.JUMP:
			velo.x = jumpVelo.x
			applyGravity(delta)
			updateAnimation()
			move()
			checkForJumpEnd()
			checkForEvent()
		STATE.EVENT:
			inputVector = Vector2.ZERO
		STATE.ATTACK:
			velo.x = 0
			pointAtTarget(delta)
			updateSnapVector()
			applyGravity(delta)
			move()
			checkForDie()
		STATE.DIE:
			$Gun.visible = false
		STATE.NOCONTROL:
			pass
		STATE.STANDBY:
			anim.play("Idle")
		
func scanForEnemies():
	if Global.healthAlly == 0:
		return 
	var enemies = scan.get_overlapping_areas()
	var dist = 9000
	var distPlayer = abs(player.global_position.x - global_position.x)
	for enemy in enemies:
		if enemy.is_in_group("Enemies") and not enemy.get_parent().allyIgnore and hasLOS(enemy):
			var enemyDist = global_position.distance_to(enemy.global_position)
			if enemyDist < dist:
				dist = enemyDist
				target = enemy
				if not target.is_connected("tree_exiting", self, "deleteTarget"):
					target.connect("tree_exiting", self, "deleteTarget")
	if dist < attackRange and is_on_floor() and distPlayer < followDist:
		state = STATE.ATTACK
		yield (get_tree().create_timer(0.1), "timeout")
		$Gun.visible = true
		yield (get_tree().create_timer(0.4), "timeout")
		fire()
	else :
		target = null
		call_deferred("scanToMove")
		
func hasLOS(enemy):
	var spaceState = get_world_2d().direct_space_state
	var result = spaceState.intersect_ray($Sprite / Center.global_position, enemy.global_position, [], 2)
	if result:
		return false
	return true

func deleteTarget():
	target = null
		
func pointAtTarget(_delta):
	if target == null:
		return 
	var tcenter = target.get_parent().center
	$Gun.look_at(tcenter.global_position)
	$Gun.scale.y = sprite.scale.x
	$AnimationPlayer.play("Shoot")
	sprite.scale.x = sign(target.global_position.x - global_position.x)
	
func fire():
	var distPlayer = abs(player.global_position.x - global_position.x)
	if distPlayer > followDist or target == null:
		call_deferred("scanToMove")
		return 
	if state == STATE.DIE:
		return 
	SFX.play("WingShoot", rand_range(0.9, 1.1))
	var tcenter = target.get_parent().center
	var dir = $Gun / Gun / Muzzle.global_position.direction_to(tcenter.global_position)
	var bullet = Utils.instanceScene(Bullet, $Gun / Gun / Muzzle.global_position)
	bullet.velo = dir * 200
	$Gun / Gun / AnimationPlayer.play("Fire")
	var bulletTween = Tween.new()
	bullet.add_child(bulletTween)
	bulletTween.interpolate_property(bullet, "velo", bullet.velo, Vector2.ZERO, 2)
	bulletTween.interpolate_property(bullet, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	bulletTween.start()
	bulletTween.connect("tween_all_completed", bullet, "queue_free")
	gunTimer.start()
	
	
func scanToMove():
	if state != STATE.JUMP and state != STATE.EVENT:
		state = STATE.MOVE
		$Gun.visible = false
		inputVector = Vector2()
		gunTimer.stop()
	
func getInputVector():
	if overrideInputVector != Vector2.ZERO:
		return overrideInputVector
	var _inputVector = inputVector
	if player != null:
		var dist = abs(player.global_position.x - global_position.x)
		if dist > followDist and inputVector.x == 0:
			_inputVector.x = sign(player.global_position.x - global_position.x)
		elif dist < stopDist:
			_inputVector.x = 0
		if not $Sprite / FloorCast.is_colliding() and command == COMMAND.waitMove:
			_inputVector.x = 0
		if command == COMMAND.stop and $Sprite.scale.x == stopDir:
			_inputVector.x = 0
	return _inputVector
	
func shortenDist(val):
	if val == true:
		followDist = 20
		stopDist = 10
	else :
		followDist = 70
		stopDist = 30
	
func facePlayer():
	if player != null:
		if inputVector.x == 0:
			$Sprite.scale.x = sign(player.global_position.x - global_position.x)
			
func applyHorizontalForce(delta):
	if inputVector.x != 0:
		velo.x += inputVector.x * acceleration * delta
		velo.x = clamp(velo.x, - maxSpeed, maxSpeed)
	if inputVector.x == 0 and abs(velo.x) < SLOPE_STOP_THRESH:
		velo.x = 0
	
func applyFriction(multiplier = 1):
	if inputVector.x == 0:
		velo.x = move_toward(velo.x, 0, friction * multiplier)
		
func updateSnapVector():
	if is_on_floor():
		snapVector = Vector2.DOWN * 4
		justJumped = false
		
func applyGravity(delta):
	if not is_on_floor():
		velo.y += gravity * delta
		velo.y = min(velo.y, maxFallSpd)
	if is_on_ceiling() and velo.y < 0:
		velo.y = 0
		
func updateAnimation():
	if is_on_floor():
		if inputVector.x != 0:
			$AnimationPlayer.play("Run")
		else :
			$AnimationPlayer.play("Idle")
	else :
		if velo.y > 0:
			$AnimationPlayer.play("JumpDown")
		else :
			$AnimationPlayer.play("JumpUp")
	if inputVector.x != 0:
			$Sprite.scale.x = sign(inputVector.x)
		
func move():
	var wasInAir = not is_on_floor()
	var wasOnFloor = is_on_floor()
	
	var stopSlope = true if get_floor_velocity().x == 0 else false
	
	
	velo = move_and_slide_with_snap(velo, snapVector, Vector2.UP, stopSlope, 4, deg2rad(46))
	if (is_on_floor() and get_floor_normal() != Vector2(0, - 1) and 
	inputVector.x == 0):
		velo.y = 1
	
	if $LandEventTimer.time_left == 0:
		if wasInAir and is_on_floor():
			randomize()
			SFX.play("Land", 1)
			for i in 5:
				var dust = Utils.instanceScene(DustEffect, global_position + Vector2((i - 2) * rand_range(0, 2), 1))
				dust.velo.x = (i - 2) * rand_range(10, 20)
				dust.velo.y = rand_range(3, - 10)
	
	
	if wasOnFloor and not is_on_floor() and not justJumped:
		pass
		
func checkForJump():
	if command == COMMAND.jump and is_on_floor():
		state = STATE.JUMP
		snapVector = Vector2()
		inputVector = Vector2.ZERO
		SFX.play("Jump", rand_range(0.7, 0.9))
		for i in 5:
			var dust = Utils.instanceScene(DustEffect, global_position + Vector2((i - 2) * rand_range(0, 2), i))
			dust.velo.x = rand_range( - 2, 2)
			dust.velo.y = rand_range( - 10, - 80)
		velo = jumpVelo
		$Sprite.scale.x = sign(velo.x)
		
func checkForJumpEnd():
	if is_on_floor():
		state = STATE.MOVE
		
func checkForEvent():
	if command == COMMAND.event:
		state = STATE.EVENT
		EventPlayer.add_animation("Event", load(currentEvent))
		EventPlayer.play("Event")

func createDustEffect():
	Utils.instanceScene(DustEffect, global_position + Vector2(rand_range( - 4, 4), 0))
	
func wallJumpEffect():
	var WallDustEffect = load("res://Effects/WallDustEffect.tscn")
	var wallDust = Utils.instanceScene(WallDustEffect, global_position + Vector2(0, - 5))
	wallDust.scale.x = sprite.scale.x
	SFX.play("Jump", rand_range(0.9, 1.1))

func _on_EventPlayer_animation_finished(anim_name):
	EventPlayer.remove_animation(anim_name)
	$LandEventTimer.start()

func playerValChanged(val):
	player = val

func _on_HurtBox_hit(damage, _knockback, _hitboxPosn):
	if state == STATE.DIE:
		return 
	Utils.instanceScene(hurtEffect, global_position - Vector2(0, 16))
	SFX.play("PlayerHurt")
	Events.emit_signal("screenShake")
	$BlinkAnimator.play("Animate")
	Global.healthAlly -= damage
	Utils.slowTimePulse(0.1, 0.4)
	
func checkForDie():
	if Global.healthAlly > 0:
		return 
	if not is_on_floor():
		return 
	state = STATE.DIE
	var effect = Utils.instanceScene(knockout, global_position - Vector2(0, 42), self)
	connect("revived", effect, "queue_free")
	$AnimationPlayer.play("Die")
	$ReviveTimer.start()

func _on_ReviveTimer_timeout():
	emit_signal("revived")
	Global.healthAlly = round(Global.maxHealthAlly / 2)
	state = STATE.MOVE
