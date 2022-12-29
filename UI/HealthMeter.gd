extends Control

onready var bar = $HPBar
onready var label = $Label
onready var staminaBar = $Stamina / StaminaBar
var barFullScale:float = 62.0
var staminaFullScale:float = 30.0
var stamRegen:float = 2.0

func _ready():
	Global.connect("healthChanged", self, "onPlayerHealthChanged")
	Global.connect("staminaChanged", self, "onPlayerStaminaChanged")
	bar.scale.x = Global.health * (barFullScale / Global.maxHealth)
	staminaBar.scale.x = float(Global.stamina * (staminaFullScale / Global.maxStamina))
	label.text = str(Global.health) + " / " + str(Global.maxHealth)
	
func onPlayerHealthChanged(_val):
	bar.scale.x = float(Global.health * (barFullScale / Global.maxHealth))
	label.text = str(Global.health) + " / " + str(Global.maxHealth)
	
func onPlayerStaminaChanged(_val):
	staminaBar.scale.x = float(Global.stamina * (staminaFullScale / Global.maxStamina))
	$Stamina / StamRegen.wait_time = stamRegen
	$Stamina / StamRegen.start()

func _on_StamRegen_timeout():
	if Global.stamina == Global.maxStamina:
		return 
	Global.stamina += 1
