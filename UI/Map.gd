extends TextureRect

const tileSize = 16

func _ready():
	modulate = Color(1, 1, 1, 0)
	MainInstances.connect("levelChanged", self, "onLevelChanged")
	
func onLevelChanged(level):
	$Sprite.position = level.mapCoords * Vector2(tileSize, tileSize)

func _process(_delta):
	if Input.is_action_just_pressed("map"):
		appear()
	if Input.is_action_just_released("map"):
		disappear()

func appear():
	if MainInstances.Player == null:
		return 
	if MainInstances.Player.state == MainInstances.Player.STATE.NOCONTROL:
		return 
	$Tween.stop_all()
	$Tween.interpolate_property(self, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 0.9), 0.2)
	$Tween.start()
	SFX.play("MapOpen")
	
func disappear():
	if MainInstances.Player == null:
		return 
	if MainInstances.Player.state == MainInstances.Player.STATE.NOCONTROL:
		return 
	$Tween.stop_all()
	$Tween.interpolate_property(self, "modulate", Color(1, 1, 1, 0.9), Color(1, 1, 1, 0), 0.2)
	$Tween.start()
	SFX.play("MapClose")
