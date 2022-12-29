extends KinematicBody2D

var ghostEffect = preload("res://Effects/BoneGhostEffect.tscn")
var DiveEffect = preload("res://Effects/BossDiveEffect.tscn")
var active = false
onready var sprite = $Sprite
onready var parent = get_parent()

func _ready():
	pass

func _process(_delta):
	if active:
		global_position.y += 10

func createGhostEffect():
	var ghost = Utils.instanceScene(ghostEffect, sprite.global_position)
	ghost.texture = sprite.texture
	ghost.hframes = sprite.hframes
	ghost.frame = sprite.frame
	ghost.scale = sprite.scale

func _on_Area2D_body_entered(_body):
	parent.boss.global_position = global_position
	parent.boss.set_physics_process(true)
	Events.emit_signal("screenShake", 5, 0.2)
	var dive = Utils.instanceScene(DiveEffect, global_position - Vector2(0, 10))
	var children = dive.get_children()
	for effect in children:
		effect.emitting = true
	SFX.play("BigThud")
	queue_free()
