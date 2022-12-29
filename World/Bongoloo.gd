extends Node2D

export  var jumpMultiplier:float = 1.5

func _on_PlayerDetector_body_entered(body):
	yield (get_tree().create_timer(0.01), "timeout")
	body.velo.y = - 1 * body.jumpHeight * jumpMultiplier
	body.state = body.STATE.SPRINGJUMP
	$AnimationPlayer.play("Animate")
	SFX.play("Boing", 1, true)

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Animate":
		$AnimationPlayer.play("Idle")
