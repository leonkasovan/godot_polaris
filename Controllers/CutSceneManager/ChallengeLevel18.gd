extends Node2D

export (String) var eventId = "L18_ChestChallenge"

onready var interact = $TreasureChest / Interact
onready var enemies = $Enemies.get_children()
var started = false
var enemiesRemaining

func _ready():
	if eventId in Global.eventsDone:
		started = true
		for enemy in enemies:
			enemy.queue_free()
		return 
	$TreasureChest.connect("opened", self, "chestOpened")
	enemiesRemaining = enemies.size()
	for enemy in enemies:
		enemy.connect("died", self, "enemyKilled")
		
func enemyKilled():
	enemiesRemaining -= 1
	if enemiesRemaining == 0:
		interact.active = true
		SFX.play("PuzzleSolved")
		
func alertEnemies():
	for enemy in enemies:
		enemy.alert()
		yield (get_tree().create_timer(0.2), "timeout")

func _on_AlertArea_body_entered(body):
	if not started:
		started = true
		alertEnemies()
		
func chestOpened():
	Global.eventsDone.append(eventId)
