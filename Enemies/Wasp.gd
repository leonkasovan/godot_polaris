extends "res://Enemies/Enemy.gd"

export  var acceleration = 100
export (float) var detectRange = 300
export (Vector2) var wanderRange = Vector2(100, 100)
var rotSpd = 1.5
var Bullet = preload("res://Enemies/WaspBullet.tscn")
var time = 0
var freq = 2
var amplitude = 6
var yPos = 0

enum STATE{
	FLOAT, 
	CHASE
}

var state = STATE.FLOAT
var player
var canShoot = false
signal died

func _ready():
	yPos = global_position.y
	call_deferred("init")
	
func init():
	player = MainInstances.Player

func _physics_process(delta):
	match state:
		STATE.FLOAT:
			detectPlayer(delta)
		STATE.CHASE:
			chasePlayer(player, delta)
		
func chasePlayer(player, delta):
	if player == null:
		return 
	var direction = ((player.center.global_position + Vector2(0, - 16)) - global_position).normalized()
	velo += direction * acceleration * delta
	velo = velo.clamped(maxSpeed)
	velo = move_and_slide(velo)
	lookAtPlayer(delta)
	
func detectPlayer(delta):
	if player == null:
		return 
	time += delta
	global_position.y = yPos + sin(time * freq) * amplitude
	if (global_position.distance_to(player.global_position) < detectRange
	 and hasLOS()):
		alert()
		
func alert():
	state = STATE.CHASE
	Utils.emote(self, 0, Vector2(0, - 32))
	SFX.play("WaspAlert")
	
func lookAtPlayer(delta):
	var dir = (player.center.global_position - global_position).normalized()
	var angleTo = $Sprite.transform.x.angle_to(dir)
	$Sprite.rotate(sign(angleTo) * min(delta * rotSpd, abs(angleTo)))
	if abs(rad2deg(angleTo)) < 10 and hasLOS() and canShoot:
		shoot()
	
func hasLOS():
	var spaceState = get_world_2d().direct_space_state
	var result = spaceState.intersect_ray($Sprite / Center.global_position, player.center.global_position, [], 2)
	if result:
		return false
	return true
	
func _on_EnemyStats_enemyDied():
	queue_free()
	createDeathExplosion()
	SFX.play("EnemyDie", rand_range(0.8, 1.1))
	SFX.play("WaspDeath", rand_range(0.9, 1.1))
	emit_signal("died")

func _on_ShootTimer_timeout():
	canShoot = true
	
func shoot():
	if player == null:
		return 
	var direction = ((player.center.global_position) - global_position).normalized()
	var bullet = Utils.instanceScene(Bullet, $Sprite / Muzzle.global_position)
	bullet.velo = direction * 200
	SFX.play("LightningBullet", rand_range(0.8, 1.1))
	canShoot = false
	$ShootTimer.start()
	
func _on_HurtBox_hit(damage, knockback, hitboxPosn):
	stats.health -= damage
	flash()
	SFX.play("EnemyHit", rand_range(0.8, 1.1))
	if state == STATE.FLOAT:
		alert()
