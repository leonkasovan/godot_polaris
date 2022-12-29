extends Light2D

var time:float = 0.0

export (bool) var byPassDarkness = false
export (float) var freq = 5
export (float) var amplitude = 0.05
var radius = 0

func _ready():
	call_deferred("init")

func init():
	randomize()
	radius = texture_scale
	time = rand_range(0, 1)
	if MainInstances.Level.isDark or byPassDarkness:
		visible = true
		if MainInstances.Level.disableShadow:
			shadow_enabled = false

func _process(delta):
	var _radius
	time += delta
	_radius = radius + sin(time * freq) * amplitude
	texture_scale = abs(_radius)
