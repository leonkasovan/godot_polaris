extends KinematicBody

var speed = 15
var velo = Vector3()

func _ready():
	set_physics_process(false)

func _physics_process(_delta):
	velo = speed * transform.basis.z
	velo = move_and_slide(velo, Vector3.UP)
	rotate_x(0.005)
	rotate_y(5e-05)
	$Ship.scale -= Vector3(0.001, 0.001, 0.001)
