class_name DashedCircleComponent2D extends Component2D

#region Export Variables
## Component-specific data that specifies circle radius, color, and dash pattern.
@export var data : DashedCircleComponentData
#endregion

#region Processing Functions
## Validates [member data] and connects [signal Data.data_changed] to trigger redraws.
func start() -> void:
	if data == null:
		push_error("DashedCircleComponent2D: No data assigned.")
		return

	data.data_changed.connect(queue_redraw)


func update(_delta : float) -> void:
	pass  # Unused lifecycle hook.


func physics_update(_deltat : float) -> void:
	pass  # Unused lifecycle hook.

func _draw() -> void:
## Draws the dashed circle centered on [member Component2D.Entity]. Skipped when [member Component2D.Enabled] is [code]false[/code] or [member data] is missing.
	if not Enabled or data == null:
		return

	draw_dashed_circle(Entity.global_position - Entity.position, data.radius * 2, data.color, data.width, data.dash_length, data.gap_length)
#endregion

#region Component Functions
## Renders a dashed arc circle using multiple [method CanvasItem.draw_arc] calls with the given dash and gap pattern.
func draw_dashed_circle(center : Vector2, radius : float, color : Color, width : float, dash_length : float, gap_length : float) -> void:
	var circumference : float = 2 * PI * radius
	var total_segments : int = int(circumference / (dash_length + gap_length))
	var angle_step : float = TAU / total_segments
	var dash_angle : float = (dash_length / circumference) * TAU
	
	for i in range(total_segments):
		var start_angle : float = i * angle_step
		var end_angle : float = start_angle + dash_angle
		var antialiased : bool = width > 0.0
		draw_arc(center, radius, start_angle, end_angle, 10, color, width, antialiased)
#endregion
