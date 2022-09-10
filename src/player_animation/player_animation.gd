extends AnimationTree

export var blackboard_path: NodePath
var blackboard: Blackboard

var grounded: bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	blackboard = get_node(blackboard_path)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if grounded:
		var velocity_length = blackboard.get_data("last_move_velocity").normalized().length()
		set("parameters/BlendSpace1D/blend_position", 
		 move_toward(get("parameters/BlendSpace1D/blend_position"), 
				velocity_length, 
				delta * 5.0))
	else:
		set("parameters/BlendSpace1D/blend_position", 0)

func _on_LocomotionGrounded_state_entered():
	grounded = true


func _on_LocomotionGrounded_state_exited():
	grounded = false
