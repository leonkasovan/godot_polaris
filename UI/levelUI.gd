extends Control

func _ready():
	Global.connect("playerDied", self, "onPlayerDied")
	MainInstances.levelUI = self
	visible = false
	
func onPlayerDied():
	visible = false
