extends KinematicBody2D

var ACCELERATION = 2000
var acceleration = ACCELERATION
var maxSpeed = 140
var friction = 20
var gravity = 700
var jumpHeight = 280
var maxFallSpd = 250
var snapVector = Vector2()
var justJumped = false
var bulletSpeed = 500
var shooting = false
var wallSlideSpd = 40
var maxSlideSpd = 180
var dashSpd = 400
var canDash = true
var obstaclePosn = Vector2()
var velo = Vector2()
var cutSceneInputVector = Vector2()
var WALLSTICK = 0.3
var wallStick = WALLSTICK
const SLOPE_STOP_THRESH = 20


var stamCostPunch:int = 10

var animOverride = false

signal fired

enum STATE{
	MOVE, 
	MOVE_POINT_UP, 
	WALL_SLIDE, 
	DOOR_JUMP, 
	HURT, 
	DASH, 
	CROUCH, 
	OBSTACLE, 
	LONGJUMP, 
	SPRINGJUMP, 
	PUNCH, 
	NOCONTROL, 
	STOPPED, 
	DEAD
}

export (STATE) var state = STATE.MOVE setget setState
export (bool) var invi = false setget setInvi

onready var anim = $AnimationPlayer
onready var sprite = $Sprite
onready var coyoteJumpTimer = $CoyoteJumpTimer
onready var jumpBufferTimer = $JumpBufferTimer
onready var jumpCoolDownTimer = $JumpCoolDownTimer
onready var muzzle = $Sprite / Muzzle
onready var bulletCooldown = $BulletCooldown
onready var shootingTimer = $ShootingTimer
onready var blinkAnimator = $BlinkAnimator
onready var cameraFollow = $CameraFollow
onready var hurtTimer = $HurtLimitTimer
onready var hurtColliders = [$HurtBox / CollisionShape2D, $HurtBoxObstacle / CollisionShape2D]
onready var useIndicator = $UseIndicator
onready var center = $Sprite / Center
onready var dashTimer = $DashDuration

var DustEffect = preload("res://Effects/DustEffect.tscn")
var PlayerBullet = preload("res://Player/PlayerBullet.tscn")
var JumpEffect = preload("res://Effects/JumpEffect.tscn")
var WallDustEffect = preload("res://Effects/WallDustEffect.tscn")
var hurtEffect = preload("res://Effects/HurtEffect.tscn")
var ghostEffect = preload("res://Effects/PlayerGhostEffect.tscn")
var punchPrepEffect = preload("res://Effects/PunchPrep.tscn")
var punchExplode = preload("res://Effects/PunchExplode.tscn")
var punchDamage = preload("res://Player/PunchDamage.tscn")
var dashEffect = preload("res://Effects/DashEffect.tscn")


signal hitDoor(door)
	
func setState(val):
	if state == STATE.WALL_SLIDE:
		$WallJumpTimer.start()
	state = val
	
func setInvi(val):
	invi = val
	$HurtBox / CollisionShape2D.disabled = val
	
func assignCamera():
	cameraFollow.remote_path = MainInstances.WorldCamera.get_path()
	
func _ready():
	bulletCooldown.wait_time = Global.bulletCooldown
	$LandEventTimer.start()

	MainInstances.Player = self
	call_deferred("assignCamera")

	self.connect("hitDoor", Game, "onPlayerHitDoor")
	if Game.testTimer.time_left == 0:
		global_position.x = Game.nextPosX
		global_position.y = Game.nextPosY
		if Game.isUpDoor:
			state = STATE.DOOR_JUMP
			velo.y = Game.upDoorVelo.y
		if Game.flipX:
			sprite.scale.x = - 1
	
func _physics_process(delta):
	match state:
		STATE.MOVE:
			var inputVector = getInputVector()
			applyHorizontalForce(inputVector, maxSpeed, delta)
			applyFriction(inputVector)
			updateSnapVector()
			jumpCheck()
			applyGravity(delta)
			checkForShoot()
			updateAnimation(inputVector)
			move(inputVector)
			checkForWallSlide()
			checkForDash()
			checkForShootDown()
			checkForCrouch()
			checkForShootUp()
			checkForPunch()
			checkForDead()
		STATE.MOVE_POINT_UP:
			var inputVector = getInputVector()
			applyHorizontalForce(inputVector, maxSpeed, delta)
			applyFriction(inputVector)
			updateSnapVector()
			jumpCheck()
			applyGravity(delta)
			checkForShoot()
			updateAnimationShootUp(inputVector)
			move(inputVector)
			checkForWallSlide()
			checkForDash()
			checkForShootUpEnd()
			checkForDead()
			checkForPunch()
		STATE.WALL_SLIDE:
			if not shooting:
				anim.play("WallSlide")
			else :
				anim.play("WallSlideShoot")
			var wallAxis = getWallAxis()
			if wallAxis != 0:
				sprite.scale.x = wallAxis
			checkForWallJump(wallAxis)
			wallSlide(delta)
			checkForShoot()
			var inputVector = Vector2.ZERO
			applyFriction(inputVector, 1)
			move(inputVector)
			checkForWallDetach(delta, wallAxis)
			checkForDash()
			checkForDead()
		STATE.DOOR_JUMP:
			var inputVector = Vector2(Game.upDoorVelo.x, 0)
			applyGravity(delta)
			applyFriction(inputVector, 1)
			applyHorizontalForce(inputVector, maxSpeed, delta)
			updateAnimation(inputVector)
			move(inputVector)
			if is_on_floor():
				state = STATE.MOVE
		STATE.HURT:
			anim.play("Hurt")
			var inputVector = Vector2.ZERO
			move(inputVector)
			applyGravity(delta)
			checkHurtRecover()
			checkForDead()
		STATE.DASH:
			anim.play("Dash")
			var inputVector = Vector2.ZERO
			updateSnapVector()
			move(inputVector)
			applyFriction(inputVector, 0.5)
			checkForWallSlide()
			checkForLongJump()
			checkForDead()
			checkForPunch()
		STATE.CROUCH:
			if not shooting:
				anim.play("Crouch")
			else :
				anim.play("CrouchShoot")
			checkForStand()
			checkForShoot()
			var inputVector = Vector2.ZERO
			applyFriction(inputVector, 2)
			updateSnapVector()
			applyGravity(delta)
			move(inputVector)
			checkForDead()
			checkForPunch()
		STATE.OBSTACLE:
			anim.play("Hurt")
			var inputVector = Vector2.ZERO
			move(inputVector)
			checkForDead()
		STATE.LONGJUMP:
			var inputVector = getInputVector()
			
			applyHorizontalForce(inputVector, maxSpeed * 1.4, delta)
			applyFriction(inputVector, 1)
			checkForWallSlide()
			applyGravity(delta)
			updateAnimation(inputVector)
			jumpCheck()
			checkForShoot()
			checkForDash()
			move(inputVector)
			checkForLongJumpEnd()
			checkForShootDown()
			checkForShootUp()
			checkForDead()
			checkForPunch()
		STATE.SPRINGJUMP:
			var inputVector = getInputVector()
			
			applyHorizontalForce(inputVector, maxSpeed, delta)
			applyFriction(inputVector, 1)
			checkForWallSlide()
			applyGravity(delta)
			updateAnimation(inputVector)
			checkForShoot()
			move(inputVector)
			checkForDash()
			checkForLongJumpEnd()
			checkForShootDown()
			checkForShootUp()
			checkForDead()
			checkForPunch()
		STATE.PUNCH:
			var inputVector = Vector2.ZERO
			move(inputVector)
		STATE.NOCONTROL:
			applyHorizontalForce(cutSceneInputVector, maxSpeed, delta)
			applyFriction(cutSceneInputVector, 5)
			applyGravity(delta)
			updateSnapVector()
			updateAnimation(cutSceneInputVector)
			move(cutSceneInputVector)
		STATE.STOPPED:
			pass
		STATE.DEAD:
			pass
			
			
	
	
func getInputVector():
	var inputVector = Vector2()
	inputVector.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	return inputVector
	
func applyHorizontalForce(inputVector, _maxSpeed, delta):
	if inputVector.x != 0:
		velo.x += inputVector.x * acceleration * delta
		velo.x = clamp(velo.x, - _maxSpeed, _maxSpeed)
	if inputVector.x == 0 and abs(velo.x) < SLOPE_STOP_THRESH:
		velo.x = 0
		
func applyFriction(inputVector, multiplier = 1):
	if inputVector.x == 0:
		velo.x = move_toward(velo.x, 0, friction * multiplier)
		
func updateSnapVector():
	if is_on_floor():
		snapVector = Vector2.DOWN * 4
		justJumped = false
		if state != STATE.DASH:
			canDash = true
	
func jumpCheck():
	if Input.is_action_just_pressed("jump"):
		jumpBufferTimer.start()
	if is_on_floor() or coyoteJumpTimer.time_left > 0:
		if (jumpBufferTimer.time_left > 0
		 and jumpCoolDownTimer.time_left == 0):
			SFX.play("Jump", rand_range(0.9, 1.1))
			velo.y = - jumpHeight
			justJumped = true
			jumpCoolDownTimer.start()
			snapVector = Vector2.ZERO
			if Input.is_action_pressed("dash"):
				self.state = STATE.LONGJUMP
			for i in 5:
				var dust = Utils.instanceScene(DustEffect, global_position + Vector2((i - 2) * rand_range(0, 2), i))
				dust.velo.x = rand_range( - 2, 2)
				dust.velo.y = rand_range( - 10, - 80)
	if not is_on_floor():
		if not Input.is_action_pressed("jump") and velo.y < - jumpHeight / 2:
			velo.y = - jumpHeight / 2
			
func applyGravity(delta):
	if not is_on_floor():
		velo.y += gravity * delta
		velo.y = min(velo.y, maxFallSpd)
	if is_on_ceiling() and velo.y < 0:
		velo.y = 0
		
func updateAnimation(inputVector):
	if animOverride:
		return 
	if not shooting:
		if is_on_floor():
			if inputVector.x != 0:
				anim.play("Run")
			else :
				anim.play("Idle")
		else :
			if velo.y > 0:
				anim.play("JumpDown")
			else :
				anim.play("JumpUp")
				
		if inputVector.x != 0:
			sprite.scale.x = sign(inputVector.x)
	else :
		if is_on_floor():
			if inputVector.x != 0:
				anim.play("ShootRun")
			elif not Input.is_action_pressed("shoot"):
				anim.play("ShootIdleStop")
		else :
			if not Input.is_action_pressed("down"):
				if velo.y > 0:
					anim.play("ShootJumpDown")
				else :
					anim.play("ShootJumpUp")
			else :
				if velo.y > 0:
					anim.play("ShootDownJumpDown")
				else :
					anim.play("ShootDownJumpUp")
				
		if inputVector.x != 0:
			sprite.scale.x = sign(inputVector.x)
			
func updateAnimationShootUp(inputVector):
		if is_on_floor():
			if inputVector.x != 0:
				anim.play("ShootUpRun")
			else :
				anim.play("ShootUp")
		else :
			if velo.y > 0:
				anim.play("ShootUpJumpDown")
			else :
				anim.play("ShootUpJumpUp")
				
		if inputVector.x != 0:
			sprite.scale.x = sign(inputVector.x)
	
func createDustEffect():
	Utils.instanceScene(DustEffect, global_position + Vector2(rand_range( - 4, 4), 0))
	
func createGhostEffect():
	if is_on_floor():
		createDustEffect()
	var ghost = Utils.instanceScene(ghostEffect, sprite.global_position)
	ghost.texture = sprite.texture
	ghost.hframes = sprite.hframes
	ghost.frame = sprite.frame
	ghost.scale = sprite.scale

func createWallDustEffect():
	Utils.instanceScene(DustEffect, global_position + Vector2(sprite.scale.x * - 4, rand_range( - 32, 0)))

func checkForShoot():
	if Input.is_action_pressed("shoot") and bulletCooldown.time_left == 0:
		shoot()
		if state == STATE.LONGJUMP:
			self.state = STATE.MOVE
		
func checkForShootUp():
	if Input.is_action_pressed("up"):
		self.state = STATE.MOVE_POINT_UP
		muzzle.position = Vector2(7, - 10)
		
func checkForShootDown():
	if Input.is_action_pressed("down") and not is_on_floor():
		muzzle.position = Vector2(5, 32)
	else :
		muzzle.position = Vector2(22, 12)
		
func checkForShootUpEnd():
	if not Input.is_action_pressed("up"):
		self.state = STATE.MOVE
		muzzle.position = Vector2(22, 12)
	
func shoot():
	var bullet = Utils.instanceScene(PlayerBullet, muzzle.global_position + Vector2(0, rand_range( - 1, 1)))
	if state != STATE.MOVE_POINT_UP:
		if not is_on_floor() and (state == STATE.MOVE or state == STATE.LONGJUMP or state == STATE.SPRINGJUMP) and Input.is_action_pressed("down"):
			bullet.velo = Vector2.DOWN * bulletSpeed
		else :
			bullet.velo.x = sprite.scale.x * bulletSpeed
	else :
		bullet.velo = Vector2.UP * bulletSpeed
	bulletCooldown.start()
	shooting = true
	shootingTimer.start()
	var inputVector = getInputVector()
	if inputVector.x == 0 and state != STATE.WALL_SLIDE and state != STATE.CROUCH and is_on_floor():
		anim.play("ShootIdle")
	emit_signal("fired")
		
func move(inputVector):
	var wasInAir = not is_on_floor()
	var wasOnFloor = is_on_floor()
	
	var stopSlope = true if get_floor_velocity().x == 0 else false
	
	velo = move_and_slide_with_snap(velo, snapVector, Vector2.UP, stopSlope, 4, deg2rad(46))
	
	if (is_on_floor() and get_floor_normal() != Vector2(0, - 1) and 
	inputVector.x == 0 and state != STATE.DASH):
		velo.y = 1
	
	
	if $LandEventTimer.time_left == 0 and state != STATE.OBSTACLE:
		if wasInAir and is_on_floor():
			randomize()
			SFX.play("Land", 1, true)
			for i in 5:
				var dust = Utils.instanceScene(DustEffect, global_position + Vector2((i - 2) * rand_range(0, 2), 1))
				dust.velo.x = (i - 2) * rand_range(10, 20)
				dust.velo.y = rand_range(3, - 10)
	
	
	if wasOnFloor and not is_on_floor() and not justJumped:
		coyoteJumpTimer.start()

func _on_ShootingTimer_timeout():
	shooting = false
	
func checkForWallSlide():
	var pressedToWall = false
	var wallAxis = getWallAxis()
	if ((Input.is_action_pressed("right") and wallAxis == - 1) or 
	(Input.is_action_pressed("left") and wallAxis == 1)):
		pressedToWall = true
	if not is_on_floor() and pressedToWall:
		self.state = STATE.WALL_SLIDE
		canDash = true
		SFX.play("Land", 1, true)
		
func getWallAxis():
	var isStick = true
	for cast in $WallCasts.get_children():
		var collide = cast.get_collider()
		if collide and collide.is_in_group("NonStick"):
			isStick = false
	if not isStick:
		return 0
	var isWallRight = $WallCasts / RightWall.is_colliding() or $WallCasts / RightWall2.is_colliding()
	var isWallLeft = $WallCasts / LeftWall.is_colliding() or $WallCasts / LeftWall2.is_colliding()
	return int(isWallLeft) - int(isWallRight)
	
func checkForWallJump(wallAxis):
	acceleration = 900
	if Input.is_action_just_pressed("jump"):
		jumpBufferTimer.start()
	if jumpBufferTimer.time_left > 0 and jumpCoolDownTimer.time_left == 0:
		jumpBufferTimer.stop()
		var wallDust = Utils.instanceScene(WallDustEffect, global_position + Vector2(0, - 5))
		wallDust.scale.x = wallAxis
		SFX.play("Jump", rand_range(0.9, 1.1))
		if Input.is_action_pressed("dash"):
			self.state = STATE.LONGJUMP
		else :
			self.state = STATE.MOVE
		velo.x = wallAxis * maxSpeed
		velo.y = - jumpHeight / 1.2

func wallSlide(delta):
	var _maxSlideSpeed = wallSlideSpd
	if Input.is_action_pressed("down"):
		_maxSlideSpeed = maxSlideSpd
	velo.y = min(velo.y + gravity * delta, _maxSlideSpeed)
	
func checkForWallDetach(delta, wallAxis):
	if ((Input.is_action_pressed("right") and wallAxis == 1) or 
	(Input.is_action_pressed("left") and wallAxis == - 1)):
		wallStick -= delta
	else :
		wallStick = WALLSTICK
	if wallStick <= 0:
		if Input.is_action_pressed("dash"):
			self.state = STATE.LONGJUMP
		else :
			self.state = STATE.MOVE
		wallStick = WALLSTICK
	if wallAxis == 0 or is_on_floor():
		self.state = STATE.MOVE
		wallStick = WALLSTICK

func _on_HurtBox_hit(damage, knockback, hitboxPosn):
	if state == STATE.NOCONTROL:
		return 
	if not invi:
		Global.health -= damage
		if state == STATE.PUNCH:
			zoomOut()
		self.state = STATE.HURT
		blinkAnimator.play("Blink")
		Utils.instanceScene(hurtEffect, global_position - Vector2(0, 16))
		var knockVelo = (global_position - hitboxPosn).normalized() * knockback
		knockVelo.y = min(knockVelo.y, - 100)
		velo = knockVelo
		snapVector = Vector2.ZERO
		hurtTimer.start()
		$DashDuration.stop()
		if state == STATE.PUNCH:
			zoomOut()
		Utils.slowTimePulse(0.1, 0.4)
	
func frameFreeze(timeScale, duration):
	Engine.time_scale = timeScale
	yield (get_tree().create_timer(duration * timeScale), "timeout")
	Engine.time_scale = 1.0
	
		
func _on_HurtBoxObstacle_obstacleHit(damage, posx, posy):
	if state == STATE.PUNCH:
		zoomOut()
	invi = true
	blinkAnimator.play("Blink")
	Global.health -= damage
	self.state = STATE.OBSTACLE
	snapVector = Vector2.ZERO
	hurtTimer.start()
	obstaclePosn = Vector2(posx, posy)
	Utils.instanceScene(hurtEffect, global_position - Vector2(0, 16))
	velo /= 20
	$ObstacleTimer.start()
	$DashDuration.stop()
	Utils.slowTimePulse(0.1, 0.4)

func checkHurtRecover():
	if is_on_floor():
		self.state = STATE.MOVE
		hurtTimer.stop()

func checkForDead():
	if Global.health == 0:
		self.state = STATE.DEAD
		$DeathSprite.scale.x = sprite.scale.x
		if $AnimationPlayer.current_animation != "Death":
			$AnimationPlayer.play("Death")
			$ObstacleTimer.stop()
			$DashDuration.stop()
			hurtTimer.stop()
			z_index = 100
			$BlinkAnimator.stop()
			$HurtBox / CollisionShape2D.disabled = true

func _on_HurtLimitTimer_timeout():
	self.state = STATE.MOVE

func checkForDash():
	if Input.is_action_just_pressed("dash") and canDash:
		canDash = false
		self.state = STATE.DASH
		velo.x = sprite.scale.x * dashSpd
		velo.y = 0
		SFX.play("Dash", 1.5)
		$DashDuration.start()
		var effect = Utils.instanceScene(dashEffect, global_position)
		effect.scale.x = sprite.scale.x

func _on_DashDuration_timeout():
	if state == STATE.DASH:
		self.state = STATE.MOVE

func checkForCrouch():
	for hurtCollider in hurtColliders:
		hurtCollider.position.y = - 15
		hurtCollider.shape.extents.y = 15
		if Input.is_action_pressed("down") and is_on_floor():
			self.state = STATE.CROUCH
			hurtCollider.position.y = - 7
			hurtCollider.shape.extents.y = 7
			muzzle.position.y = 22
		
func checkForStand():
	if not Input.is_action_pressed("down"):
		self.state = STATE.MOVE

func _on_ObstacleTimer_timeout():
	$LandEventTimer.start()
	self.state = STATE.MOVE
	global_position = obstaclePosn
	Events.emit_signal("pulsePixel", 0.02, 1)

func _on_WallJumpTimer_timeout():
	acceleration = ACCELERATION
		
		
func wallJumpGhost():
	if state == STATE.DOOR_JUMP or state == STATE.LONGJUMP or state == STATE.SPRINGJUMP:
		createGhostEffect()
		
func checkForLongJump():
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		canDash = true
		self.state = STATE.LONGJUMP
		SFX.play("Jump", rand_range(0.9, 1.1))
		velo.y = - jumpHeight
		justJumped = true
		jumpCoolDownTimer.start()
		snapVector = Vector2.ZERO
		for i in 5:
			var dust = Utils.instanceScene(DustEffect, global_position + Vector2((i - 2) * rand_range(0, 2), i))
			dust.velo.x = rand_range( - 2, 2)
			dust.velo.y = rand_range( - 10, - 80)
			
func checkForLongJumpEnd():
	if is_on_floor():
		self.state = STATE.MOVE
		
func checkForPunch():
	if not Global.canPunch:
		return 
	if Global.stamina < stamCostPunch:
		return 
	if Input.is_action_just_pressed("special"):
		Utils.slowTimePulse(0.5, 0.8)
		$BlinkAnimator.stop()
		anim.play("Punch")
		self.state = STATE.PUNCH
		SFX.play("Punch")
		Events.emit_signal("zoom", 0.8, 0.25)
		$Tween.interpolate_property(self, "velo", velo, Vector2.ZERO, 0.2)
		$Tween.start()
		Events.emit_signal("screenShake", 0.5, 0.6, 60)
		yield (get_tree().create_timer(0.1), "timeout")
		var effect = Utils.instanceScene(punchPrepEffect, global_position - Vector2(sprite.scale.x * 14, 18), self)
		effect.rotation_degrees = rand_range(0, 360)
		
func zoomOut():
	Events.emit_signal("zoom", 1.0, 0.8)

func releasePunch():
	Global.stamina -= stamCostPunch
	Events.emit_signal("screenShake", 2, 0.4, 60, 2)
	var effect = Utils.instanceScene(punchExplode, global_position + Vector2(sprite.scale.x * 30, - 18), self)
	effect.rotation_degrees = 90
	effect.scale.y = sprite.scale.x

	var damage = Utils.instanceScene(punchDamage, global_position + Vector2(sprite.scale.x * 30, - 18), self)

func _on_Player_tree_exited():
	MainInstances.Player = null
