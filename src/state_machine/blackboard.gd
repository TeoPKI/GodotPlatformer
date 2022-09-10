class_name Blackboard
extends Node

signal data_changed(key, data)
# Store data that needs to be referenced cross states
# Access / Save with a string key
# based on blackboard implementation: https://github.com/kagenash1/godot-behavior-tree
export var data: Dictionary;

func _enter_tree():
	data = data.duplicate()

func set_data(key: String, value):
	data[key] = value
	emit_signal("data_changed",key, value)

func get_data(key: String):
	if data.has(key):
		var value = data[key]
		if value is NodePath:
			if value.is_empty() :
				data[key] = null
				return null
			else:
				emit_signal("data_changed",key, value)
				return get_node(value)
		else:
			emit_signal("data_changed",key, value)
			return value
	else:
		return null
