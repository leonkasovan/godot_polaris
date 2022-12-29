extends CanvasLayer

onready var bar = $BossHealthMeter / HPBar
onready var label = $BossHealthMeter / Label
onready var parent = get_parent()
var barFullScale:float = 62.0
var fullHealth = 0.0

func _ready():

	Global.connect("playerDied", self, "onPlayerDied")
	call_deferred("init")
	
func onEnemyHealthChanged(val):
	bar.scale.x = float(val * (barFullScale / fullHealth))
	label.text = str(val) + " / " + str(fullHealth)
	
func init():
	parent.connect("enemyHealthChanged", self, "onEnemyHealthChanged")
	fullHealth = parent.health
	parent.setHealth(1)
	bar.scale.x = 0
	label.text = str(parent.health) + " / " + str(fullHealth)

func onPlayerDied():
	$BossHealthMeter.visible = false
