extends Sprite

var targetPosn = Vector2()

func _ready():
	modulate = Color(1, 1, 1, 0)
	call_deferred("init")
	
func init():
	targetPosn = Vector2(global_position.x, global_position.y - 42)
	$Tween.interpolate_property(self, "global_position", global_position, targetPosn, 3, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.interpolate_property(self, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 1)
	$Tween.start()

func destroy():
	$Tween.stop_all()
	$Tween.interpolate_property(self, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 1)
	$Tween.start()
	yield (get_tree().create_timer(1.0), "timeout")
	queue_free()
