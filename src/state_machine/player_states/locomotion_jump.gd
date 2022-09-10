extends State

export var grounded_state_path: NodePath
export var falling_state_path: NodePath
export var double_jump_state_path: NodePath

export var jump_curve: Curve
export var jump_speed: float = 1
export var min_jump_progress: float = 0.5

onready var ground_state = get_node(grounded_state_path)
onready var falling_state = get_node(falling_state_path)
onready var double_jump_state = get_node(double_jump_state_path)

var last_ground_velocity: Vector3
var kinematic_body: KinematicBody
var jump_progress: float = 0
var snap: Vector3 = Vector3.ZERO
var jump_queued: bool
var view_root: Spatial

func state_exit(bb: Blackboard):
	.state_exit(bb)
	

func state_enter(bb: Blackboard):
	.state_enter(bb)
	jump_queued = false
	jump_progress = 0
	last_ground_velocity = bb.get_data("last_ground_velocity")
	last_ground_velocity.y = 0 # this will be overriden by jump velocity
	kinematic_body = bb.get_data("kinematic_body")
	snap = Vector3.ZERO
	var jump_count: int = bb.get_data("jump_count")
	bb.set_data("jump_count", jump_count + 1)
	view_root = bb.get_data("view_root")
	var anim: AnimationTree = bb.get_data("animation_tree") as AnimationTree

	
func state_input(event: InputEvent, bb: Blackboard) -> State:
	# allow queueing second jump immediately after jump is finished
	if event.is_action_pressed("jump") && bb.get_data("jump_count") < 2:
		jump_queued = true
	return null


func state_physics_process(delta: float, bb: Blackboard) -> State:
	jump_progress += delta * jump_speed
	jump_progress = clamp(jump_progress, 0, 1)
	var jump: float = jump_curve.interpolate(jump_progress) * jump_speed
	var velocity = last_ground_velocity + Vector3.UP * jump

#	if last_ground_velocity != Vector3.ZERO:
#		var look_dir = atan2(last_ground_velocity.x, last_ground_velocity.z)
#		view_root.rotation.y = lerp_angle(view_root.rotation.y, look_dir, 0.1)

	
	# Currently if we dont do this trick we land immediately when jumping on a slope
	if jump_progress >= min_jump_progress:
		snap = Vector3.DOWN
	else:
		snap = Vector3.ZERO
		
	var previous_velocity = kinematic_body.move_and_slide_with_snap(velocity, snap, Vector3.UP, false, 4)
	
	bb.set_data("last_move_velocity", previous_velocity)
	
	if kinematic_body.is_on_floor() && snap == Vector3.DOWN:
		return ground_state
	
	# Hit our head ow!
	if kinematic_body.is_on_ceiling():
		return falling_state
	
	if is_equal_approx(jump_progress, 1):
		if(jump_queued):
			return double_jump_state
		return falling_state

	return null
