extends CanvasLayer

func _ready():

	$PauseMenu.connect("unpaused", self, "unpaused")
	
func unpaused():
	if $Map.modulate != Color(1, 1, 1, 0):
		$Map.disappear()
