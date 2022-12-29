extends Node

var Player = null setget _playerValChanged
var Ally = null
var WorldCamera = null
var Level = null setget _levelChanged
var levelUI = null

signal playerValChanged(val)
signal levelChanged(val)

func _playerValChanged(val):
	Player = val
	emit_signal("playerValChanged", val)

func _levelChanged(val):
	Level = val
	emit_signal("levelChanged", val)
