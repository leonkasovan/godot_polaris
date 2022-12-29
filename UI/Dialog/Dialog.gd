extends CanvasLayer

export (String, FILE, "*.JSON") var dialogPath = ""
export (float) var textSpeed = 0.025

var dialog
var dialogString = ""
var phraseNum = 0
var finished = false

var volume

onready var dialogBox = $DialogBox

func _ready():
	volume = $Voice.volume_db
	call_deferred("startDialog")
	var useButton = Global.keybinds["use"]
	var scancode = useButton[0].get_scancode()
	$DialogBox / Indicator / UseLabel.text = OS.get_scancode_string(scancode)
	
func startDialog():
	if dialogPath == "":
		startDialogString()
		return 
	$Timer.wait_time = textSpeed
	dialog = get_dialog()
	assert (dialog, "dialog not found!!	")
	nextPhrase()
	
func startDialogString():
	$Timer.wait_time = textSpeed
	dialog = [{
		"Text":dialogString
	}]
	nextPhrase()

func _process(_delta):
	$DialogBox / Indicator.visible = finished
	if (Input.is_action_just_pressed("use") or Input.is_action_just_pressed("ui_accept")) and $CanSkip.time_left == 0:
		if finished:
			nextPhrase()
		else :
			$DialogBox / Text.visible_characters = len($DialogBox / Text.text)

func get_dialog()->Array:
	var f = File.new()
	assert (f.file_exists(dialogPath), "File path does not exist!")
	
	f.open(dialogPath, File.READ)
	var json = f.get_as_text()
	
	var output = parse_json(json)
	
	if typeof(output) == TYPE_ARRAY:
		return (output)
	else :
		return []
		
func nextPhrase():
	if phraseNum >= len(dialog):
		queue_free()
		return 
	finished = false
	if dialog[phraseNum].has("Name"):
		$DialogBox / Name.bbcode_text = dialog[phraseNum]["Name"]
		if dialog[phraseNum].has("NameOverride"):
			$DialogBox / Name.bbcode_text = dialog[phraseNum]["NameOverride"]
	else :
		$DialogBox / Name.bbcode_text = ""
	$DialogBox / Text.bbcode_text = dialog[phraseNum]["Text"]
	$DialogBox / Text.visible_characters = 0
	
	var f = File.new()
	if dialog[phraseNum].has("Emotion"):
		var checker = "res://UI/Dialog/Portraits/" + dialog[phraseNum]["Name"] + dialog[phraseNum]["Emotion"] + ".png.import"
		if f.file_exists(checker):
			var img = "res://UI/Dialog/Portraits/" + dialog[phraseNum]["Name"] + dialog[phraseNum]["Emotion"] + ".png"
			$DialogBox / Portrait.texture = load(img)
			$DialogBox / Name.margin_left = 90
			$DialogBox / Text.margin_left = 98
		else :
			$DialogBox / Portrait.texture = null
			$DialogBox / Name.margin_left = 20
			$DialogBox / Text.margin_left = 28
	else :
		$DialogBox / Portrait.texture = null
		$DialogBox / Name.margin_left = 20
		$DialogBox / Text.margin_left = 28
	
	var fi = File.new()
	var snd = ""
	var sndCheck = ""
	if dialog[phraseNum].has("Name"):
		sndCheck = "res://Music and Sounds/SFX/Voices/" + dialog[phraseNum]["Name"] + "Voice.wav.import"
	if fi.file_exists(sndCheck):
		snd = "res://Music and Sounds/SFX/Voices/" + dialog[phraseNum]["Name"] + "Voice.wav"
		$Voice.stream = load(snd)
	else :
		$Voice.stream = load("res://Music and Sounds/SFX/Voices/DefaultVoice.wav")
	
	while $DialogBox / Text.visible_characters < len($DialogBox / Text.text):
		$DialogBox / Text.visible_characters += 1
		if not $Voice.playing:
			$Voice.pitch_scale = rand_range(0.9, 1.1)
			$Voice.volume_db = volume + SFX.sfxVolume
			$Voice.play()
		$Timer.start()
		yield ($Timer, "timeout")
	
	finished = true
	phraseNum += 1
	return 
