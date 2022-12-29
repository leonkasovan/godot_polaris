extends Node2D

var player
export (String) var chestId = ""
export (String) var itemId = ""
export (bool) var showTextTop = false

var popEffect = preload("res://Items/TreasureItemPop.tscn")
var text = "You got nothing loser!"
var sound = ""
var pop
var frame

var enemies
signal opened

func _ready():
	call_deferred("init")
	
func init():
	if chestId in Global.openChests:
		alreadyGot()
		return 
	var dict = Game.item.get(itemId)
	frame = dict[0]
	text = "You got " + "'" + dict[1] + "'.\n" + dict[2]
	sound = dict[3]
	$Interact.connect("interact", self, "open")
	player = MainInstances.Player
	
func alreadyGot():
	$Sprite.frame = 1
	$Interact.active = false
	
func open():
	emit_signal("opened")
	enemies = get_tree().get_nodes_in_group("Enemies")
	for enemy in enemies:
		enemy.set_physics_process(false)
	Global.openChests.append(chestId)
	Music.changeVolume( - 10)
	SFX.play("ChestOpen")
	$Interact.active = false
	player.state = player.STATE.NOCONTROL
	$Sprite.frame = 1
	$Sparkles.emitting = true
	Events.emit_signal("zoom", 0.7, 1.5)
	yield (get_tree().create_timer(1.5), "timeout")
	SFX.play(sound)
	pop = Utils.instanceScene(popEffect, global_position)
	pop.frame = frame
	yield (get_tree().create_timer(1.5), "timeout")
	var dia = Utils.startDialogString(text, showTextTop)
	dia.connect("tree_exited", self, "resume")
	
func resume():
	pop.destroy()
	player.state = player.STATE.MOVE
	Events.emit_signal("zoom", 1.0, 1.5)
	if Game.has_method(itemId):
		Game.call(itemId)
	Music.play(MainInstances.Level.music)
	enemies = get_tree().get_nodes_in_group("Enemies")
	for enemy in enemies:
		enemy.set_physics_process(true)
