extends Node2D

export (Vector2) var mapCoords = Vector2()
export (bool) var isDark = false
export (Color) var DarkColor = null
export (bool) var disableShadow = false
export (bool) var UIoff = false
export (String) var music = null
export (bool) var stopMusic = false
export (bool) var lowerMusic = false
export (float) var musicTransTime = 1.0
var Modulate = preload("res://Effects/DarknessModulate.tscn")

func _ready():
	MainInstances.Level = self
	if music != null:
		Music.play(music, musicTransTime)
	if stopMusic:
		Music.stop(musicTransTime)
	if lowerMusic:
		Music.changeVolume( - 80, musicTransTime)
	call_deferred("init")
func init():
	if isDark:
		var mod = Utils.instanceScene(Modulate, global_position, self)
		if DarkColor != null:
			mod.color = DarkColor
			
	MainInstances.levelUI.visible = true
	if MainInstances.Ally != null:
		MainInstances.Ally.UI.visible = true
	if UIoff:
		MainInstances.levelUI.visible = false
		if MainInstances.Ally != null:
			MainInstances.Ally.UI.visible = false
		
func _exit_tree():
	MainInstances.levelUI.visible = false
