extends Node2D

onready var cover = $CanvasLayer / ColorRect
onready var anim = $AnimationPlayer
onready var tw = $Tween
signal repositionNow

func _ready():
	anim.play("FadeIn")

	Events.connect("roomTransition", self, "roomTransition")

	Events.connect("roomTransitionSlow", self, "roomTransitionSlow")

	Events.connect("repositionEvent", self, "repositionEvent")

func roomTransition():
	anim.play("FadeOut")
	
func fadeIn():
	anim.play("FadeIn")
	
func roomTransitionSlow(roomNext:String = "", transTime = 2.0):
	anim.playback_speed = 1 / transTime
	anim.play("FadeOutSlow")
	Game.nextRoom = roomNext
	yield (get_tree().create_timer(transTime - 0.1), "timeout")
	Game.testTimer.start()

func changeRoomSlow():
	Game.roomTransitionCam()
	yield (get_tree().create_timer(0.5), "timeout")
	anim.play("FadeInSlow")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "FadeInSlow":
		anim.playback_speed = 1.0


func repositionEvent():
	anim.stop()
	tw.interpolate_property(cover, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.3)
	tw.start()
	yield (get_tree().create_timer(0.3), "timeout")
	emit_signal("repositionNow")
	tw.interpolate_property(cover, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.3)
	tw.start()
	yield (get_tree().create_timer(0.3), "timeout")



