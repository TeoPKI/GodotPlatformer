extends ImmediateGeometry

const visible_duration: float = 0.02

var previous_position: Vector3
var positions: Array
var timer: Timer
var parent: Spatial

func _ready():
	parent = get_parent()
	set_as_toplevel(true)
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = visible_duration
	timer.autostart = true
	timer.connect("timeout",self,"remove_oldest_point")
	timer.start()

func _physics_process(_delta):
	if(parent.get_global_transform_interpolated().origin != previous_position):
		positions.append(parent.get_global_transform_interpolated().origin)
		
	draw_lines()
	
	previous_position = get_parent().get_global_transform_interpolated().origin

func draw_lines():
	clear()
	begin(Mesh.PRIMITIVE_LINES)
	set_color(Color(1,1,1,1))

	for n in positions.size() - 1:
		add_vertex(positions[n])
		add_vertex(positions[n + 1])

	end()

func remove_oldest_point():
	if positions.size() >= 2:
		positions.remove(0)
