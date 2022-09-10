class_name StateMachine
extends Node

export var base_state: NodePath
export var blackboard_path: NodePath

onready var blackboard = get_node(blackboard_path)

signal state_changed(new_state)

var current_state: State

func _ready():
	var default_state: State = get_node(base_state)
	transition_to(default_state)

# exit old state and enter new state
func transition_to(state: State):
	if current_state != null:
		current_state.state_exit(blackboard)
		
	state.state_enter(blackboard)
	current_state = state
	emit_signal("state_changed", state)

func find_state(state: String) -> State:
	return find_node(state) as State

func _process(delta: float):
	var new_state = current_state.state_process(delta, blackboard)
	if new_state:
		transition_to(new_state)

func _physics_process(delta: float):
	var new_state = current_state.state_physics_process(delta, blackboard)
	if new_state:
		transition_to(new_state)

func _input(event: InputEvent):
	var new_state = current_state.state_input(event, blackboard)
	if new_state:
		transition_to(new_state)
