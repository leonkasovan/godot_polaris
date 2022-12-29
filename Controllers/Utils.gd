extends Node

func _input(_event):
	if Input.is_action_just_pressed("ui_fullscreen"):
		OS.window_fullscreen = not OS.window_fullscreen

func instanceScene(scene, posn, parent = null):
	var level = MainInstances.Level
	var instance = scene.instance()
	if parent == null:
		level.add_child(instance)
	else :
		parent.add_child(instance)
	instance.global_position = posn
	return instance
	
func startDialog(dialogPathString, showTop = false):
	var level = MainInstances.Level
	var instance = load("res://UI/Dialog/Dialog.tscn").instance()
	level.add_child(instance)
	instance.dialogPath = dialogPathString
	if showTop:
		instance.dialogBox.rect_position.y = 50
	return instance
	
func startDialogString(_string, showTop = false):
	var level = MainInstances.Level
	var instance = load("res://UI/Dialog/Dialog.tscn").instance()
	level.add_child(instance)
	instance.dialogString = _string
	if showTop:
		instance.dialogBox.rect_position.y = 50
	return instance
	
func listChildren():
	var level = MainInstances.Level
	var list = level.get_children()
	print(list)
	
func checkForDupes(array):
	var dupes = false
	var unique_numbers = []
	for n in array:
		if not n in unique_numbers:
			unique_numbers.append(n)
	if array.size() != unique_numbers.size():
		dupes = true
	return dupes
	
func emote(object, emote, offset = Vector2()):
	var instance = load("res://UI/Emotes/Emote.tscn").instance()
	object.add_child(instance)
	instance.global_position = object.global_position + offset
	instance.emote = emote
	
func facePlayer(object_id, sprite):
	var player = MainInstances.Player
	if player != null:
		sprite.scale.x = sign(player.global_position.x - object_id.global_position.x)
		
func playerFace(object_id):
	var player = MainInstances.Player
	if player != null:
		player.sprite.scale.x = sign(object_id.global_position.x - player.global_position.x)
		
func slowTimePulse(scale, duration):
	Engine.time_scale = scale
	yield (get_tree().create_timer(duration * scale), "timeout")
	Engine.time_scale = 1.0
	
func yieldTime(time:float = 1.0):
	yield (get_tree().create_timer(time), "timeout")
