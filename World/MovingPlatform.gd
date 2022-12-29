extends Node2D

export  var idle_dur:float = 1.0
export  var move_to = Vector2.RIGHT * 64
export  var speed:float = 100

onready var platform = $Platform
onready var tween = $MoveTween

signal shortenDist(val)

func _ready():
	var dur = move_to.length() / speed
	tween.interpolate_property(platform, "position", Vector2.ZERO, move_to, dur, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, idle_dur)
	tween.interpolate_property(platform, "position", move_to, Vector2.ZERO, dur, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, dur + idle_dur * 2)
	tween.start()
	call_deferred("connectAllySignal")
		
func connectAllySignal():
	if MainInstances.Ally != null:

		connect("shortenDist", MainInstances.Ally, "shortenDist")
		
func _on_PlayerDetector_body_entered(_body):
	emit_signal("shortenDist", true)

func _on_PlayerDetector_body_exited(_body):
	$Platform / PlayerDetector / LeftPlatform.start()

func _on_LeftPlatform_timeout():
	emit_signal("shortenDist", false)
