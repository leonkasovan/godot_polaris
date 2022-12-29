tool 
extends EditorPlugin

var shake = 0.0
var shake_intensity = 0.0
var timer = 0.0
var last_key = ""
var pitch_increase: = 0.0
const PITCH_DECREMENT: = 2.0

const Boom = preload("boom.tscn")
const Blip = preload("blip.tscn")
const Newline = preload("newline.tscn")


func _enter_tree():
	var editor = get_editor_interface()
	var script_editor = editor.get_script_editor()
	script_editor.connect("editor_script_changed", self, "editor_script_changed")


func _exit_tree():
	pass


var editors = {}
func get_all_text_editors(parent:Node):
	for child in parent.get_children():
		if child.get_child_count():
			get_all_text_editors(child)
			
		if child is TextEdit:
			editors[child] = {"text":child.text, "line":child.cursor_get_line()}
			
			if child.is_connected("cursor_changed", self, "cursor_changed"):
				child.disconnect("cursor_changed", self, "cursor_changed")
			child.connect("cursor_changed", self, "cursor_changed", [child])
				
			if child.is_connected("text_changed", self, "text_changed"):
				child.disconnect("text_changed", self, "text_changed")
			child.connect("text_changed", self, "text_changed", [child])

			if child.is_connected("gui_input", self, "gui_input"):
				child.disconnect("gui_input", self, "gui_input")
			child.connect("gui_input", self, "gui_input")


func gui_input(event):
	
	if event is InputEventKey and event.pressed:
		event = event as InputEventKey
		last_key = OS.get_scancode_string(event.get_scancode_with_modifiers())
		

func editor_script_changed(script):
	var editor = get_editor_interface()
	var script_editor = editor.get_script_editor()
	
	editors.clear()
	get_all_text_editors(script_editor)


func _process(delta):
	var editor = get_editor_interface()
	
	if shake > 0:
		shake -= delta
		editor.get_base_control().rect_position = Vector2(rand_range( - shake_intensity, shake_intensity), rand_range( - shake_intensity, shake_intensity))
	else :
		editor.get_base_control().rect_position = Vector2.ZERO

	timer += delta
	if (pitch_increase > 0.0):
		pitch_increase -= delta * PITCH_DECREMENT


func shake(duration, intensity):
	if shake > 0:
		return 
		
	shake = duration
	shake_intensity = intensity
	
	
func cursor_changed(textedit):
	var editor = get_editor_interface()
	
	if not editors.has(textedit):
		
		
		editors.clear()
		get_all_text_editors(editor.get_script_editor())
		
	editors[textedit]["line"] = textedit.cursor_get_line()


func text_changed(textedit:TextEdit):
	var editor = get_editor_interface()
	var settings = editor.get_editor_settings()
	
	if not editors.has(textedit):
		
		
		editors.clear()
		get_all_text_editors(editor.get_script_editor())
		
	
	var line = textedit.cursor_get_line()
	var column = textedit.cursor_get_column()
	
	
	var tab_size = settings.get_setting("text_editor/indent/size")
	var line_text = textedit.get_line(line).substr(0, column)
	column += line_text.count("	") * (tab_size - 1)
	
	
	var vscroll = textedit.scroll_vertical
	var hscroll = textedit.scroll_horizontal
	
	
	
	
	
	
	
	
	
	
	textedit.scroll_vertical = vscroll
	
	
	var line_spacing = settings.get_setting("text_editor/theme/line_spacing")
	
	
	var font:DynamicFont = DynamicFont.new()
	font.font_data = load(settings.get_setting("interface/editor/code_font"))
	font.size = settings.get_setting("interface/editor/code_font_size")
	var fontsize = font.get_string_size(" ")
	
	
	var pos = Vector2()
	pos.x = (column) * (fontsize.x) - hscroll + 90
	pos.y = (line - vscroll) * (fontsize.y + line_spacing - 2) + 10

	if editors.has(textedit):
		
		if timer > 0.1 and len(textedit.text) < len(editors[textedit]["text"]):
			timer = 0.0
			
			
			var thing = Boom.instance()
			thing.position = pos
			thing.destroy = true
			thing.last_key = last_key
			textedit.add_child(thing)
			
			
			shake(0.1, 3)
		
		if timer > 0.02 and len(textedit.text) >= len(editors[textedit]["text"]):
			timer = 0.0

			
			var thing = Blip.instance()
			thing.pitch_increase = pitch_increase
			pitch_increase += 1.0
			thing.position = pos
			thing.destroy = true
			thing.last_key = last_key
			textedit.add_child(thing)
			
			
			shake(0.05, 3)
			
		










	editors[textedit]["text"] = textedit.text
	editors[textedit]["line"] = textedit.cursor_get_line()
