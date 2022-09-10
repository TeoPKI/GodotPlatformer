extends Label



func _on_StateMachine_state_changed(new_state):
	text = "Current State: " + new_state.name
