extends Node


var lastRoom:String = ""
var maxHealth:int = 50
var maxStamina:int = 10
var bulletCooldown:float = 0.3

var canPunch:bool = false
var eventsDone:Array = []

var openChests:Array = []


var health = maxHealth setget healthChanged
var stamina = maxStamina setget staminaChanged
var maxHealthAlly = 12
var healthAlly = maxHealthAlly setget healthChangedAlly

func clearSave():
	lastRoom = ""
	maxHealth = 50
	maxStamina = 10
	bulletCooldown = 0.3
	
	canPunch = false
	eventsDone = []
	
	openChests = []

	
signal playerDied
signal allyDied
signal healthChanged(val)
signal staminaChanged(val)
signal healthChangedAlly(val)

func getSaveItems():
	var items = {
		"lastRoom":lastRoom, 
		"maxHealth":maxHealth, 
		"maxStamina":maxStamina, 
		"bulletCooldown":bulletCooldown, 
		
		"canPunch":canPunch, 
		"eventsDone":eventsDone, 
		
		"openChests":openChests, 
	}
	return items

func saveGame():
	var saveFile = File.new()
	saveFile.open("user://saveFile.save", File.WRITE)
	var saveItems = getSaveItems()
	saveFile.store_line(to_json(saveItems))
	saveFile.close()
	
func loadGame():
	var saveFile = File.new()
	if not saveFile.file_exists("user://saveFile.save"):
		return 
	saveFile.open("user://saveFile.save", File.READ)
	while not saveFile.eof_reached():
		var lineString = saveFile.get_line()
		if lineString != "":
			var currentLine = parse_json(lineString)
			if currentLine != null:
				for property in currentLine.keys():
					set(property, currentLine[property])
	saveFile.close()
	healthChanged(maxHealth)


var keybinds = {
	"up":null, 
	"down":null, 
	"left":null, 
	"right":null, 
	"shoot":null, 
	"jump":null, 
	"dash":null, 
	"use":null, 
	"special":null, 
	"map":null
}

func saveKeyBinds():
	var config = ConfigFile.new()
	for key in keybinds:
		config.set_value("keybinds", key, keybinds[key])
	config.set_value("preferences", "fullscreen", OS.is_window_fullscreen())
	config.set_value("preferences", "sfxVolume", SFX.sfxVolume)
	config.set_value("preferences", "musicVolume", Music.musicVolume)
	config.save("user://keybinds.cfg")
	
func loadKeyBinds():
	var config = ConfigFile.new()
	var checker = config.load("user://keybinds.cfg")
	if checker != OK:
		return 
	var keys = config.get_section_keys("keybinds")
	for action in keys:
		InputMap.action_erase_events(action)
		var buttons = config.get_value("keybinds", action)
		for button in buttons:
			InputMap.action_add_event(action, button)
	OS.set_window_fullscreen(config.get_value("preferences", "fullscreen", false))
	SFX.sfxVolume = config.get_value("preferences", "sfxVolume", 0)
	Music.musicVolume = config.get_value("preferences", "musicVolume", 0)
			
func getActions():
	var actions = InputMap.get_actions()
	var actionList = {}
	for i in actions:
		actionList[i] = InputMap.get_action_list(i)
	for a in keybinds.keys():
		for i in actionList.keys():
			if i == a:
				keybinds[a] = actionList[i]

func healthChanged(val):
	if val < health:
		Events.emit_signal("screenShake", 5, 0.2)
		Events.emit_signal("pulseChrom", 0.75, 0.5)
		SFX.play("PlayerHurt", 1, true)
	health = clamp(val, 0, maxHealth)
	emit_signal("healthChanged", val)
	if health == 0:
		emit_signal("playerDied")
		
func staminaChanged(val):
	stamina = clamp(val, 0, maxStamina)
	emit_signal("staminaChanged", val)
		
func healthChangedAlly(val):
	healthAlly = clamp(val, 0, maxHealthAlly)
	emit_signal("healthChangedAlly", healthAlly)
	if health == 0:
		emit_signal("allyDied")
		
func _ready():
	call_deferred("init")
	
func init():
	loadGame()
	loadKeyBinds()
	getActions()
