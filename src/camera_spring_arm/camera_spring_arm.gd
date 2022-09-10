extends SpringArm


export var mouse_sensitivity :=  0.05
export var lerp_speed = 3.0
export var height := 1.35


var parent: Spatial

func _ready():
	# translate independently from our parent
	parent = get_parent()
	set_as_toplevel(true)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	physics_interpolation_mode = PHYSICS_INTERPOLATION_MODE_OFF

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.x -= event.relative.y * mouse_sensitivity
		rotation_degrees.x = clamp(rotation_degrees.x, -90.0, 30.0)
		
		rotation_degrees.y -= event.relative.x * mouse_sensitivity
		rotation_degrees.y = wrapf(rotation_degrees.y, 0.0, 360.0)

func _process(delta):
	var target_transform = parent.get_global_transform_interpolated()
	var target_origin = target_transform.translated(Vector3.UP * height).origin
	transform.origin = transform.origin.linear_interpolate(target_origin, delta * lerp_speed)
