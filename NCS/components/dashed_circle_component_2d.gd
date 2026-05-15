class_name DashedCircleComponent2D extends Component2D

#region Export Variables
@export var data : DashedCircleComponentData # Base component data, change to component specific data type
#endregion

#region Variables

#endregion

#region Processing Functions
func start() -> void:
	# put ready logic here
	if data:
		data.data_changed.connect(queue_redraw)

func update(_delta : float) -> void:
	# Put process logic here
	pass

func physics_update(_deltat : float) -> void:
	# Put physics process logic here
	pass

func _draw() -> void:
	if !Enabled:
		return
		
	draw_dashed_circle(Entity.global_position - Entity.position, data.radius * 2, data.color, data.width, data.dash_length, data.gap_length)
#endregion

#region Component Functions
func draw_dashed_circle(center : Vector2, radius : float, color : Color, width : float, dash_length : float, gap_length : float) -> void:
	var circumference : float = 2 * PI * radius
	var total_segments : int = int(circumference / (dash_length + gap_length))
	var angle_step : float = TAU / total_segments
	var dash_angle : float = (dash_length / circumference) * TAU
	
	for i in range(total_segments):
		var start_angle : float = i * angle_step
		var end_angle : float = start_angle + dash_angle
		var antialiased : bool = false
		if width > 0:
			antialiased = true
		draw_arc(center, radius, start_angle, end_angle, 10, color, width, antialiased)
#endregion
