extends "res://src/state_machine/state.gd"

export var kinematic_body_path: NodePath
export var falling_state_path: NodePath
export var jump_state_path: NodePath

export var normal_speed: float = 3
export var acceleration : float = 5

onready var kinematic_body: KinematicBody = get_node(kinematic_body_path)
onready var falling_state: State = get_node(falling_state_path)
onready var jump_state: State = get_node(jump_state_path)

var is_crouching: bool
var target_move: Vector3
var previous_velocity: Vector3
var player_camera_pivot: Spatial
var view_root: Spatial
const SLOPE_LIMIT: int = 45

#signal crouched
#signal stood_up

func state_enter(bb: Blackboard):
	.state_enter(bb)
	if player_camera_pivot == null:
		player_camera_pivot = bb.get_data("player_camera_pivot")
#	head_clearance_area = bb.get_data("head_clearance_area")
	var is_moving = (Input.is_action_pressed("move_forward") 
			|| Input.is_action_pressed("move_backward")
			|| Input.is_action_pressed("move_left")
			||  Input.is_action_pressed("move_right"))
	# experimental? if no input, movement is stopped else inherit velocity
	if(!is_moving):
		target_move = Vector3.ZERO
	view_root = bb.get_data("view_root")
	bb.set_data("jump_count", 0)

func state_physics_process(delta: float, bb: Blackboard) -> State:
	var direction: Vector2 = Vector2.ZERO
	
	if Input.is_action_pressed("move_forward"):
		direction.y -= 1
	if Input.is_action_pressed("move_backward"):
		direction.y += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1
		
	var anim: AnimationTree = bb.get_data("animation_tree") as AnimationTree


		
	direction = direction.normalized()
	var move: Vector3 = Vector3.ZERO
	move.x = direction.x
	move.z = direction.y
	# Rotate move vector by camera yaw
	var yaw: float = player_camera_pivot.rotation_degrees.y
	var rad: float = deg2rad(yaw)
	move = move.rotated(Vector3.UP, rad)
	
#	target_move = target_move.linear_interpolate(move * get_speed(), delta * acceleration)
	target_move = target_move.move_toward(move * get_speed(), delta * acceleration)
	var snap: Vector3
	snap = -kinematic_body.get_floor_normal()

	previous_velocity = kinematic_body.move_and_slide_with_snap(target_move, snap, 
			Vector3.UP, true, 
			4,0.785398,false)
	
#	var dir_length = direction.length()
#
#	anim["parameters/BlendSpace1D/blend_position"] = move_toward(
#				anim["parameters/BlendSpace1D/blend_position"],
#				dir_length, 
#				delta * 2.0 if dir_length > 0 else delta * 5.0)
#
	bb.set_data("last_move_velocity", previous_velocity)
	
	if move != Vector3.ZERO:
		var look_dir = atan2(move.x, move.z)
		view_root.rotation.y = lerp_angle(view_root.rotation.y, look_dir, 0.2)
	
	if kinematic_body.is_on_floor() == false:
		bb.set_data("last_ground_velocity", previous_velocity)
		return falling_state
		
	if Input.is_action_just_pressed("jump"):
		bb.set_data("last_ground_velocity", previous_velocity)
		return jump_state
	
	return null

func get_speed() -> float:
	return normal_speed
