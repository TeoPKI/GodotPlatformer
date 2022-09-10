extends "res://src/state_machine/state.gd"

export var kinematic_body_path: NodePath
export var grounded_state_path: NodePath
export var jump_state_path: NodePath
export var ledge_state_path: NodePath

export var gravity: float = 1
export var horizontalDrag: float = 1

onready var grounded_state: State = get_node(grounded_state_path)
onready var jump_state: State = get_node(jump_state_path)
onready var ledge_state: State = get_node(ledge_state_path)

var kinematic_body: KinematicBody
var current_gravity: Vector3 = Vector3.ZERO

const SLOPE_LIMIT: int = 45

func cache_state():
	kinematic_body = get_node(kinematic_body_path)
	
func state_enter(bb: Blackboard):
	.state_enter(bb)
	current_gravity = bb.get_data("last_ground_velocity")
	current_gravity.y = -gravity * 0.016667
	var anim: AnimationTree = bb.get_data("animation_tree") as AnimationTree


func state_physics_process(delta: float, bb: Blackboard) -> State:
	current_gravity.y -= gravity * delta
	current_gravity.x = move_toward(current_gravity.x, 0, delta * horizontalDrag);
	current_gravity.z = move_toward(current_gravity.z, 0, delta * horizontalDrag);

	var velocity = kinematic_body.move_and_slide(current_gravity, Vector3.UP, true, 4, 0.785398, false)
	
	bb.set_data("last_move_velocity", velocity)
	# allow only maximum of two jumps to happen before its reset by another state
	if Input.is_action_just_pressed("jump") && bb.get_data("jump_count") < 2:
		return jump_state
	
	if kinematic_body.is_on_floor():
		return grounded_state
		

	var ledge_info = bb.get_data("ledge_detector").detect()
	if ledge_info != null:
		bb.set_data("ledge_transform", ledge_info[0])
		bb.set_data("ledge_body", ledge_info[1])
		return ledge_state
	
	
	return null
