extends "res://Enemies/Enemy.gd"

export (float) var warningSpeed = 1.0
var falling = false
var grav = 500

var Destroy = load("res://Effects/StalactiteDestroyParticles.tscn")

func _ready():
	$AnimationPlayer.playback_speed = warningSpeed

	$HitBox.connect("hit", self, "destroy")

func _physics_process(delta):
	if falling:
		velo.y += grav * delta

		move_and_slide(velo, Vector2.UP)

func alerted():
	if not falling:
		$AnimationPlayer.play("Shake")
	
func fall():
	falling = true
	$AnimationPlayer.play("Idle")
	$HitBox / CollisionShape2D.disabled = false

func _on_PlayerDetector_body_entered(_body):
	alerted()

func destroy():
	var effect = Utils.instanceScene(Destroy, global_position + Vector2(0, 8))
	effect.emitting = true
	Events.emit_signal("screenShake")
	SFX.play("Stalactite", rand_range(0.9, 1.1))
	queue_free()

func _on_GroundDetector_body_entered(_body):
	destroy()

func _on_VisibilityNotifier2D_screen_exited():
	if falling:
		queue_free()
