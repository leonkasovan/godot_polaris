extends Node2D

onready var testTimer = $TestTimer

var nextRoom = null
var nextPosX = null
var nextPosY = null
var isUpDoor = false
var upDoorVelo = Vector2()
var flipX = null
var resumeSound = null
var intendedDeath = false

export (String, FILE, "*.JSON") var HeartNutDialog = null

var gpButtons = {
	0:"Xbox A", 
	1:"Xbox B", 
	2:"Xbox X", 
	3:"Xbox Y", 
	4:"L1", 
	5:"R1", 
	6:"L2", 
	7:"R2", 
	8:"L3", 
	9:"R3", 
	10:"Select", 
}

var item = {
	
	"HeartNut":[0, "Heart-shaped Alien Nut", "Increases Max Health.", "PowerUpGet"], 
	"AlienScrew":[1, "Alien Screw-Shaft", "Increases Weapon Firing Rate.", "PowerUpGet"], 
	
}
func HeartNut():
	var eventId = "HeartNutGet"
	Global.maxHealth += 10
	Global.health = Global.maxHealth
	if not eventId in Global.eventsDone:
		Global.eventsDone.append(eventId)
		MainInstances.Player.state = MainInstances.Player.STATE.NOCONTROL
		var dia = Utils.startDialog(HeartNutDialog)
		dia.connect("tree_exited", self, "resume")
		resumeSound = "Eat"
		
func AlienScrew():
	Global.bulletCooldown -= 0.05
	MainInstances.Player.bulletCooldown.wait_time = Global.bulletCooldown
	
func resume():
	MainInstances.Player.state = MainInstances.Player.STATE.MOVE
	if resumeSound != null:
		SFX.play(resumeSound)
		resumeSound = null

func _ready():
	Engine.set_target_fps(Engine.get_iterations_per_second())
	Global.connect("playerDied", self, "onPlayerDied")
	
func onPlayerHitDoor(door):
	Events.emit_signal("roomTransition")
	nextRoom = door.nextRoom
	nextPosX = door.nextPosX
	nextPosY = door.nextPosY
	isUpDoor = door.isUpDoor
	upDoorVelo = door.upDoorVelo
	flipX = door.flipX
	
func roomTransitionCam():

	get_tree().change_scene(nextRoom)
	
func onPlayerDied():
	if intendedDeath:
		return 
	Music.stop(0)
	yield (get_tree().create_timer(0.8), "timeout")
	SFX.playOverride("PlayerDeath")
	$DeathTimer.start()

func _on_DeathTimer_timeout():
	if Global.lastRoom != "":
		nextRoom = Global.lastRoom
	else :
		nextRoom = "res://Levels/Level_0.tscn"
	Global.health = Global.maxHealth
	Global.stamina = Global.maxStamina
	Global.healthAlly = Global.maxHealthAlly
	Events.emit_signal("roomTransitionSlow", nextRoom)
	yield (get_tree().create_timer(1.9), "timeout")
	$TestTimer.start()
