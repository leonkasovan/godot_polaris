extends Node2D

export (Array, String, FILE, "*.JSON") var dialog
onready var BG = [$Camera / CameraBackground / Sky / BGPrologue, $Camera / CameraBackground / Parallax1 / BGCanyon, $Camera / CameraBackground / Parallax2 / BGCanyon2]
var spawned = false
var spawned3 = false
var Player
var started = false
var podSpeed = 0
var podAccelerate = 0.7
var podStarted = false

func _ready():
	call_deferred("init")
	
func _process(delta):
	if not podStarted:
		return 
	podSpeed += podAccelerate
	$EscapePod.global_position.y -= podSpeed * delta

func init():
	Game.intendedDeath = true
	Global.connect("playerDied", self, "onDeath")
	for bg in BG:
		bg.modulate = Color("ff5959")
	MainInstances.Level.isDark = true
	MainInstances.Level.init()
	Player = MainInstances.Player
	for light in get_tree().get_nodes_in_group("FlickerLight"):
		light.init()

func _on_Trigger_body_entered(_body):
	if started:
		return 
	started = true
	Player.state = Player.STATE.NOCONTROL
	Player.velo.x = 0
	yield (get_tree().create_timer(2.0), "timeout")
	var dia = Utils.startDialog(dialog[0])
	dia.connect("tree_exited", self, "standUp")
	
func standUp():
	yield (get_tree().create_timer(1.0), "timeout")
	$EscapePod / Leo / LeoAnim.play("IdleStand")
	yield (get_tree().create_timer(1.0), "timeout")
	var dia = Utils.startDialog(dialog[1])
	dia.connect("tree_exited", self, "punch")
	
func punch():
	Player.animOverride = true
	Player.anim.play("Push")
	yield (get_tree().create_timer(0.3), "timeout")
	$EscapePod / Leo / LeoAnim.play("Push")
	SFX.play("BigThud", 2.0)
	yield (get_tree().create_timer(0.4), "timeout")
	SFX.play("MapOpen")
	Player.animOverride = false
	
func pushShake():
	Events.emit_signal("screenShake")

func _on_LeoAnim_animation_finished(anim_name):
	if anim_name == "Push":
		var dia = Utils.startDialog(dialog[2])
		dia.connect("tree_exited", self, "launch")
		
func launch():
	SFX.play("TakeOff")
	yield (get_tree().create_timer(1.8), "timeout")
	$EscapePod / Body / Boost.visible = true
	Events.emit_signal("screenShake", 0.5, 5)
	podStarted = true
	yield (get_tree().create_timer(5), "timeout")
	Music.play("MainMenu", 3)
	for i in $Spawners.get_children():
		i.spawn()
	yield (get_tree().create_timer(3), "timeout")
	for e in get_tree().get_nodes_in_group("Enemies"):
		e.set_physics_process(false)
	yield (get_tree().create_timer(2.5), "timeout")
	var dia = Utils.startDialog(dialog[3])
	dia.connect("tree_exited", self, "resume")
	
func resume():
	for e in get_tree().get_nodes_in_group("Enemies"):
		e.set_physics_process(true)
	Player.state = Player.STATE.MOVE
	
func onDeath():
	yield (get_tree().create_timer(2.5), "timeout")
	Events.emit_signal("roomTransitionSlow", "res://Controllers/DemoEnd.tscn", 3.0)
