extends Node2D

signal enemyDied
signal enemyHealthChanged(value)

export (int) var maxHealth = 1
onready var health = maxHealth setget setHealth

func setHealth(val):
	if val < health:
		Events.emit_signal("screenShake", 1, 0.2)
	health = clamp(val, 0, maxHealth)
	emit_signal("enemyHealthChanged", health)
	if health == 0:
		emit_signal("enemyDied")
		Events.emit_signal("screenShake", 3, 0.3)
