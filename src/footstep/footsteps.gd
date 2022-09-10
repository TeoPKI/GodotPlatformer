class_name Footsteps
extends Spatial

# Footsteps for anything. Typically animated characters that call methods
# from AnimationPlayer etc...

export var dirt_steps_path: NodePath
export var rock_steps_path: NodePath
export var grass_steps_path: NodePath
export var wood_steps_path: NodePath

signal footstep


func play_footstep(volume: float = 1):
	var node = get_node(dirt_steps_path)
	var count = node.get_child_count()
	
	if(count == 0):
		return
	
	var stream_player = node.get_child(rand_range(0,count))
	var db = linear2db(volume)
	# spawn a "one shot" clone of a stream player if the sound would overlap
	if stream_player.is_playing():
		var instance = stream_player.duplicate()
#		instance.volume_db = db
		node.add_child(instance)
		instance.connect("finished", instance, "queue_free")
		instance.play()
	else:
#		stream_player.volume_db = db
		stream_player.play()
	
	emit_signal("footstep")
