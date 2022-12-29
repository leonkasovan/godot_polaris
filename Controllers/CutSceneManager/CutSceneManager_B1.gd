extends Node2D

export (Array, String, FILE, "*.JSON") var dialogPath = null
export (String) var preBossEventId = "LB1_PrebossDialog"

var player = null
onready var boss = $BoneBoss
onready var interact = $Interact
var Dust = preload("res://Effects/DustEffect.tscn")
var bossDefeated = false

var startClose = false
var closed = false

var targetX:float = 0.0

func _ready():
	boss.connect("defeated", self, "onBossDefeated")
	interact.connect("interact", self, "interacted")
	targetX = global_position.x - 49
	if Global.canPunch:
		$Artifact / Ring.queue_free()
		interact.active = false
		
func _process(_delta):
	if not closed and startClose:
		if $Door.global_position.x > targetX:
			$Door.global_position.x -= 1
		else :
			closed = true
			doorClosed()

func dustEffect():
	Utils.instanceScene(Dust, $Door.global_position + Vector2(rand_range( - 30, - 10), 0))
	Utils.instanceScene(Dust, $Door.global_position + Vector2(rand_range( - 30, - 10), - 64))
	
func _on_DustTimer_timeout():
	if closed:
		$Door / DustTimer.stop()
	dustEffect()

func interacted():
	if not bossDefeated:
		player = MainInstances.Player
		player.state = player.STATE.NOCONTROL
		interact.active = false
		if preBossEventId in Global.eventsDone:
			closeDoor()
			return 
		var dia = Utils.startDialog(dialogPath[0])
		dia.connect("tree_exited", self, "closeDoor")

func closeDoor():
	startClose = true
	$Door / DustTimer.start()
	Utils.emote(player, 0, Vector2(0, - 50))
	player.sprite.scale.x = 1
	
func doorClosed():
	Events.emit_signal("screenShake", 5, 0.15)
	SFX.play("BigThud")
	yield (get_tree().create_timer(1.0), "timeout")
	$BoneBossSpawner.active = true
	SFX.play("BoneBossDash")
	Utils.emote(player, 0, Vector2(0, - 50))
	player.sprite.scale.x = - 1
	yield (get_tree().create_timer(3.0), "timeout")
	if preBossEventId in Global.eventsDone:
		startFight()
		return 
	var dia = Utils.startDialog(dialogPath[1])
	dia.connect("tree_exited", self, "startFight")
	
func startFight():
	boss.init()
	if not preBossEventId in Global.eventsDone:
		Global.eventsDone.append(preBossEventId)
	
func onBossDefeated():
	yield (get_tree().create_timer(2.0), "timeout")
	var dia = Utils.startDialog(dialogPath[2])
	dia.connect("tree_exited", self, "bossExit")
	
func bossExit():
	yield (get_tree().create_timer(1.0), "timeout")
	boss.exitStage()
	yield (get_tree().create_timer(2.5), "timeout")
	var dia = Utils.startDialog(dialogPath[3])
	dia.connect("tree_exited", self, "resume")
	
func resume():
	player.state = player.STATE.MOVE
	bossDefeated = true


func _on_Area2D_body_entered(body):
	if bossDefeated:
		Events.emit_signal("pulseChrom", 1.0, 2.0)
		SFX.play("SavePointHum")
		body.state = body.STATE.STOPPED
		$Artifact / Ring / Modulate.play("ModulateAnimation")
		yield (get_tree().create_timer(3.0), "timeout")
		$Artifact / Ring.queue_free()
		player.state = player.STATE.NOCONTROL
		yield (get_tree().create_timer(1.0), "timeout")
		lastDialog()
		
func lastDialog():
	var dia = Utils.startDialog(dialogPath[4])
	dia.connect("tree_exited", self, "lastDialogDone")
		
func lastDialogDone():
	player.state = player.STATE.MOVE
	Global.canPunch = true
	Global.saveGame()
	yield (get_tree().create_timer(2.0), "timeout")
	$Tween.interpolate_property($Door, "global_position", $Door.global_position, $Door.global_position + Vector2(48, 0), 1)
	$Tween.start()
