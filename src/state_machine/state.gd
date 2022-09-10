# Generic base class for all states.
# You should not use this class directly but inherit from it.
class_name State
extends Node

signal state_entered
signal state_exited

func _ready():
	cache_state()

func state_enter(_bb: Blackboard):
	emit_signal("state_entered")

func state_exit(_bb: Blackboard):
	emit_signal("state_exited")

# Called once at _ready()
# Override this function to cache or initialize stuff etc.
func cache_state():
	pass
	
func state_process(_delta: float, _bb: Blackboard) -> State:
	return null
	
func state_physics_process(_delta: float, _bb: Blackboard) -> State:
	return null

func state_input(_event: InputEvent, _bb: Blackboard) -> State:
	return null
