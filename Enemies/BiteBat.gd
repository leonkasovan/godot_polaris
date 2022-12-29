extends "res://Enemies/Enemy.gd"

var acceleration = 100

func _ready():
	set_physics_process(false)

func _physics_process(delta):
	var player = MainInstances.Player
	if player != null:
		chasePlayer(player, delta)
		
func chasePlayer(player, delta):
	var direction = (player.global_position - global_position).normalized()
	velo += direction * acceleration * delta
	velo = velo.clamped(maxSpeed)
	velo = move_and_slide(velo)

func _on_VisibilityNotifier2D_screen_entered():
	set_physics_process(true)
