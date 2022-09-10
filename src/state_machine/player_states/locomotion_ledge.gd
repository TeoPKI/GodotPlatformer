extends State

export var jump_state_path: NodePath

onready var jump_state = get_node(jump_state_path)

var previous_platform_position: Vector3

func state_enter(bb: Blackboard):
	.state_enter(bb)
	bb.get_data("kinematic_body").global_transform.origin = bb.get_data("ledge_transform").origin
	bb.get_data("view_root").global_transform = bb.get_data("ledge_transform")
	previous_platform_position = bb.get_data("ledge_body").global_transform.origin
	
func state_physics_process(delta: float, bb: Blackboard) -> State:
	
	var platform_velocity = (bb.get_data("ledge_body").global_transform.origin - previous_platform_position) / delta
	bb.get_data("kinematic_body").move_and_slide(platform_velocity)
	previous_platform_position = bb.get_data("ledge_body").global_transform.origin
	
	if Input.is_action_just_pressed("jump"):
		var forward: Vector3 = bb.get_data("view_root").global_transform.basis.z.normalized()
		var dot = forward.dot(platform_velocity.normalized())
		# hacky? apply forward velocity so we dont get stuck in place when going to jump state
		# by using dot above we make sure we always end up landing on top platform 

		bb.set_data("last_ground_velocity",forward * 2 if platform_velocity == Vector3.ZERO 
				else (platform_velocity + (forward)) * inverse_lerp(-1, 0,dot)) 
		bb.set_data("jump_count", 0)
		return jump_state
		
	return null
