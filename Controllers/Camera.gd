extends Camera2D

var amplitude = 0
var shakePriority = 0
var nextScene = null
var nextPosX = null
var nextPosY = null

onready var durTimer = $ShakeDuration
onready var freqTimer = $ShakeFrequency
onready var tween = $Tween
onready var shadePixel = $Shaders / Pixelize
onready var shadeChrom = $Shaders / ChromAber
onready var chromTimer = $ChromTimer
onready var pixelTimer = $PixelTimer
onready var main = get_tree().current_scene

signal roomTransitionCam()

func _ready():
	if Game.testTimer.time_left == 0:
		global_position.x = Game.nextPosX
		global_position.y = Game.nextPosY
	$AnimationPlayer.play("FadeIn")

	self.connect("roomTransitionCam", Game, "roomTransitionCam")

	Events.connect("screenShake", self, "screenShake")

	Events.connect("pulseChrom", self, "pulseChrom")

	Events.connect("pulsePixel", self, "pulsePixel")

	Events.connect("roomTransition", self, "roomTransition")
	MainInstances.WorldCamera = self

	Global.connect("playerDied", self, "onPlayerDied")

	Events.connect("zoom", self, "zoom")
	
func _exit_tree():
	MainInstances.WorldCamera = null
	
func mainVisible(val):
	main.visible = val


func screenShake(amp = 2, dur = 0.2, freq = 30, priority = 0):
	if priority < shakePriority:
		return 
	shakePriority = priority
	amplitude = amp
	durTimer.wait_time = dur
	freqTimer.wait_time = 1 / float(freq)
	durTimer.start()
	freqTimer.start()
	
	newShake()

func newShake():
	var rand = Vector2()
	rand.x = rand_range( - amplitude, amplitude)
	rand.y = rand_range( - amplitude, amplitude)
	tween.interpolate_property(self, "offset", offset, rand, freqTimer.wait_time, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()
	
func reset():
	tween.interpolate_property(self, "offset", offset, Vector2(), freqTimer.wait_time, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()

func _on_ShakeFrequency_timeout():
	newShake()

func _on_ShakeDuration_timeout():
	reset()
	freqTimer.stop()
	shakePriority = 0
	
func pulseChrom(amp = 0.75, dur = 0.5):
	shadeChrom.visible = true
	tween.interpolate_property(shadeChrom.get_material(), "shader_param/amount", amp, 0.0, dur, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	chromTimer.wait_time = dur
	chromTimer.start()
	
func pulsePixel(amp, dur):
	shadePixel.visible = true
	tween.interpolate_property(shadePixel.get_material(), "shader_param/size_x", amp, 0.0, dur, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.interpolate_property(shadePixel.get_material(), "shader_param/size_y", amp, 0.0, dur, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	pixelTimer.wait_time = dur - 0.1
	pixelTimer.start()

func _on_ChromTimer_timeout():
	shadeChrom.visible = false
	
func roomTransition():
	$AnimationPlayer.play("FadeOut")
	
func fadeIn():
	$AnimationPlayer.play("FadeIn")
	emit_signal("roomTransitionCam")

func _on_PixelTimer_timeout():
	shadePixel.visible = false
	
func onPlayerDied():
	$DeathRect.visible = true
	
func zoom(_scale, transTime = 1.0):
	tween.stop(self, "zoom")
	tween.interpolate_property(self, "zoom", zoom, Vector2(_scale, _scale), transTime, Tween.TRANS_SINE, Tween.EASE_OUT)
	tween.start()
