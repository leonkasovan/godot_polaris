extends CanvasLayer

onready var bar = $AllyHealthMeter / HPBar
onready var label = $AllyHealthMeter / Label
onready var parent = get_parent()
var barFullScale:float = 62.0
var fullHealth = 0

func _ready():

	Global.connect("playerDied", self, "onPlayerDied")
	call_deferred("init")
	
func onAllyHealthChanged(val):
	bar.scale.x = float(val * (barFullScale / fullHealth))
	label.text = str(val) + " / " + str(fullHealth)
	
func init():

	Global.connect("healthChangedAlly", self, "onAllyHealthChanged")
	fullHealth = Global.maxHealthAlly
	label.text = str(Global.healthAlly) + " / " + str(fullHealth)
	onAllyHealthChanged(Global.healthAlly)

func onPlayerDied():
	$AllyHealthMeter.visible = false
	
