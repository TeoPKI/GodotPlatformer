extends Spatial




func _on_Area_body_entered(body):
	get_node("KinematicBody/AnimationPlayer").play("Bounce")
