extends Node2D

var Player:KinematicBody2D = null
var Ally:KinematicBody2D = null
export (Array, String, FILE, "*.JSON") var dialogPath = null
export (Array, String) var eventId = ["L5_Preboss", "L5_Postboss"]
export  var playerReposition = Vector2()
export  var AllyReposition = Vector2()
export  var playerXScale = 1
export  var AllyXScale = 1
var event2Triggered = false

onready var shipSprite = $Camera / CameraBackground / Parallax0 / Sprite
onready var BG = [$Camera / CameraBackground / Parallax0 / Sprite, $Camera / CameraBackground / Sky / BGPrologue, $Camera / CameraBackground / Parallax1 / BGCanyon, $Camera / CameraBackground / Parallax2 / BGCanyon2]
var newSprite = preload("res://World/SpaceShipDestroyedBG.png")

func _ready():
	call_deferred("init")

func init():
	Player = MainInstances.Player
	Ally = MainInstances.Ally
	if Global.canPunch:
		var enemies = get_tree().get_nodes_in_group("Enemies")
		for enemy in enemies:
			enemy.queue_free()

	TransitionCover.connect("repositionNow", self, "reposition")
	if eventId[1] in Global.eventsDone:
		event2Triggered = true
		var enemies = get_tree().get_nodes_in_group("Enemies")
		for enemy in enemies:
			enemy.queue_free()
		Music.play("ColdBreeze", 0)
		var spawners = $Spawners.get_children()
		for spawner in spawners:
			spawner.spawn()
		Ally.overrideInputVector.x = - 1
		shipSprite.texture = newSprite
		$Nuke.queue_free()
		$Camera / CameraBackground / Parallax0 / Smoke.emitting = true
		for bg in BG:
			bg.modulate = Color("ff5959")
		MainInstances.Level.isDark = true
		MainInstances.Level.init()
		for light in get_tree().get_nodes_in_group("FlickerLight"):
			light.init()
		$Embers.emitting = true

func _on_Trigger_body_entered(player):
	if not Global.canPunch and not eventId[0] in Global.eventsDone:
		Events.emit_signal("repositionEvent")
		player.state = player.STATE.NOCONTROL
		Global.eventsDone.append(eventId[0])
	elif Global.canPunch and not event2Triggered:
		event2Triggered = true
		Events.emit_signal("repositionEvent")
		player.state = player.STATE.NOCONTROL
		Music.stop(2)
		
func reposition():
	Player.animOverride = true
	Player.anim.play("IdleBack")
	Ally.state = Ally.STATE.NOCONTROL
	Ally.anim.play("IdleBack")
	Player.global_position = playerReposition
	Ally.global_position = AllyReposition
	Player.sprite.scale.x = playerXScale
	Ally.sprite.scale.x = AllyXScale
	yield (get_tree().create_timer(1.0), "timeout")
	if not Global.canPunch:
		var dia = Utils.startDialog(dialogPath[0])
		dia.connect("tree_exited", self, "resume")
	else :
		var dia = Utils.startDialog(dialogPath[1])
		dia.connect("tree_exited", self, "shipExplode")
		
func shipExplode():
	SFX.play("ShipDestroy")
	Events.emit_signal("screenShake", 1, 12)
	$Tween.interpolate_property($WorldEnvironment.environment, "glow_intensity", 0, 5, 8)
	$Tween.interpolate_property($WorldEnvironment.environment, "glow_strength", 0, 2, 8)
	$Tween.interpolate_property($WorldEnvironment.environment, "glow_bloom", 0, 1, 8)
	$Tween.interpolate_property($Nuke, "position", $Nuke.position, $Nuke.position + Vector2(0, 200), 8)
	$Tween.start()
	yield (get_tree().create_timer(8), "timeout")
	shipSprite.texture = newSprite
	$Nuke.queue_free()
	$Camera / CameraBackground / Parallax0 / Smoke.emitting = true
	$Camera / CameraBackground / Parallax0 / Smoke.emitting = true
	for bg in BG:
		bg.modulate = Color("ff5959")
	MainInstances.Level.isDark = true
	MainInstances.Level.init()
	for light in get_tree().get_nodes_in_group("FlickerLight"):
		light.init()
	$Embers.emitting = true
	$Tween.stop_all()
	$Tween.interpolate_property($WorldEnvironment.environment, "glow_intensity", 5, 0, 4)
	$Tween.interpolate_property($WorldEnvironment.environment, "glow_strength", 2, 0, 4)
	$Tween.interpolate_property($WorldEnvironment.environment, "glow_bloom", 1, 0, 4)
	$Tween.start()
	yield (get_tree().create_timer(5), "timeout")
	var dia = Utils.startDialog(dialogPath[2])
	dia.connect("tree_exited", self, "spawnTheHornets")
	
func spawnTheHornets():
	Utils.emote(Player, 0, Vector2(0, - 50))
	Utils.emote(Ally, 0, Vector2(0, - 50))
	Player.anim.play("Idle")
	Ally.anim.play("Idle")
	var spawners = $Spawners.get_children()
	for spawner in spawners:
		spawner.spawn()
	Music.play("ColdBreeze", 0)
	yield (get_tree().create_timer(3), "timeout")
	var enemies = get_tree().get_nodes_in_group("Enemies")
	for enemy in enemies:
		enemy.set_physics_process(false)
	var dia = Utils.startDialog(dialogPath[3])
	dia.connect("tree_exited", self, "resume2")
	
func resume():
	Player.animOverride = false
	Player.state = Player.STATE.MOVE
	Ally.state = Ally.STATE.MOVE

func resume2():
	Global.lastRoom = "res://Levels/Level_5.tscn"
	if not eventId[1] in Global.eventsDone:
		Global.eventsDone.append(eventId[1])
	Player.animOverride = false
	Player.state = Player.STATE.MOVE
	Ally.state = Ally.STATE.MOVE
	Ally.overrideInputVector.x = - 1
	var enemies = get_tree().get_nodes_in_group("Enemies")
	for enemy in enemies:
		enemy.set_physics_process(true)
