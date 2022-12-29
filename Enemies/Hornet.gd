extends "res://Enemies/Enemy.gd"

export  var acceleration = 100
export (PackedScene) var elec
var rotSpd = 1
var time = 0
var freq = 2
var amplitude = 6
var yPos = 0

enum STATE{
	FLOAT, 
	CHASE
}

var state = STATE.CHASE
var player
var canShoot = false
signal died

func _ready():
	yPos = global_position.y
	call_deferred("init")
	
func init():
	player = MainInstances.Player
	$ElecTimer.wait_time = rand_range(1, 2)
	$ElecTimer.start()

func _physics_process(delta):
	match state:
		STATE.FLOAT:
			pass
		STATE.CHASE:
			chasePlayer(delta)
		
func chasePlayer(delta):
	if player == null:
		return 
	var direction = ((player.center.global_position + Vector2(0, - 16)) - global_position).normalized()
	velo += direction * acceleration * delta
	velo = velo.clamped(maxSpeed)
	velo = move_and_slide(velo)
	lookAtPlayer(delta)
	
func lookAtPlayer(delta):
	var dir = (player.center.global_position - global_position).normalized()
	var angleTo = $Sprite.transform.x.angle_to(dir)
	$Sprite.rotate(sign(angleTo) * min(delta * rotSpd, abs(angleTo)))
	
func _on_EnemyStats_enemyDied():
	queue_free()
	createDeathExplosion()
	SFX.play("EnemyDie", rand_range(0.8, 1.1))
	SFX.play("WaspDeath", rand_range(0.9, 1.1))
	emit_signal("died")


func _on_ElecTimer_timeout():
	var effect = Utils.instanceScene(elec, $Sprite / Muzzle.global_position, $Sprite / Muzzle)
	effect.rotation_degrees = rand_range(0, 360)
	$ElecTimer.wait_time = rand_range(1, 2)
	$ElecTimer.start()
