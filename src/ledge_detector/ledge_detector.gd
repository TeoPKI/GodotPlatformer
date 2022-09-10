extends Spatial

onready var front_ray: RayCast = $FrontRay
onready var front_ray_left: RayCast = $FrontRayLeft
onready var front_ray_right: RayCast = $FrontRayRight

onready var top_ray_left: RayCast = $TopRayLeft
onready var top_ray_right: RayCast = $TopRayRight


func detect():
#	front_ray.force_update_transform()
#	front_ray_left.force_update_transform()
#	front_ray_right.force_update_transform()
	front_ray.force_raycast_update()
	front_ray_left.force_raycast_update()
	front_ray_right.force_raycast_update()
	
	var front_colliding: bool = (front_ray.is_colliding() 
			&& front_ray_left.is_colliding()
			&& front_ray_right.is_colliding())

	if front_colliding:
		var front_left_distance = front_ray_left.global_transform.origin.distance_to(
					front_ray_left.get_collision_point())
		var front_right_distance = front_ray_right.global_transform.origin.distance_to(
				front_ray_right.get_collision_point())
				
#		var equal_normals = (front_ray.get_collision_normal().is_equal_approx(
#					front_ray_left.get_collision_normal()) 
#					&& front_ray.get_collision_normal().is_equal_approx(
#					front_ray_right.get_collision_normal()))
		# epsilon is too small for comparison so check dot products are within treshold
		var dot1 = front_ray.get_collision_normal().dot(front_ray_left.get_collision_normal())
		var dot2 = front_ray.get_collision_normal().dot(front_ray_right.get_collision_normal())
		var equal_normals = dot1 > 0.98 && dot2 > 0.98
#		print(front_ray.get_collision_normal(), front_ray_left.get_collision_normal(), front_ray_right.get_collision_normal(), equal_normals)
		var angle = front_ray.get_collision_normal().angle_to(Vector3.UP)

		if !is_zero_approx(rad2deg(angle) - 90.0):
			return null

		if equal_normals == false:
			return null

		top_ray_left.translation.z = front_left_distance + 0.2
		top_ray_right.translation.z = front_right_distance + 0.2
		
		top_ray_left.force_update_transform()
		top_ray_right.force_update_transform()
		
		top_ray_right.force_raycast_update()
		top_ray_left.force_raycast_update()
		
		var top_colliding: bool = (top_ray_left.is_colliding() 
				&& top_ray_right.is_colliding())
				
		if top_colliding == false:
			return null
			
		var top_hit_left: Transform = top_ray_left.global_transform
		var top_hit_right: Transform = top_ray_right.global_transform
		top_hit_left.origin = top_ray_left.get_collision_point()
		top_hit_right.origin = top_ray_right.get_collision_point()
		
		var center_transform: Transform = top_hit_left.interpolate_with(
				top_hit_right, 0.5)
				
		var check_transform = center_transform

		var space = get_world().direct_space_state
		var shape: CapsuleShape = CapsuleShape.new()
		shape.height = 1.0
		shape.radius = 0.3
		var query = PhysicsShapeQueryParameters.new()
		query.shape_rid = shape.get_rid()
		# apparently this shape is already up-right roation? unlike collision shapes in editor WTF
		# needs confirmation
#		check_transform = check_transform.rotated(Vector3.RIGHT, deg2rad(90.0))
		query.transform = check_transform.translated(Vector3.UP)
		query.exclude = [get_owner()] # ignore self
		var results = space.intersect_shape(query, 1)

		if results.size() > 0:
			return null
		
		var dir = center_transform.origin + front_ray.get_collision_normal()
		dir.y = center_transform.origin.y
		center_transform = center_transform.looking_at(dir, Vector3.UP)
		center_transform = center_transform.translated(Vector3.FORWARD * 0.55 + Vector3.DOWN * 1.8)
		
		return [center_transform,front_ray.get_collider()]
	
	return null


