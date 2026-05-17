class_name OrbitComponent2D extends Component2D

#region Export Variables
## Component-specific data configuration for orbit speed, distance, and direction.
@export var data : OrbitComponentData
## The Node2D around which to orbit.
@export var target : Node2D
#endregion

#region Variables
var current_angle : float = 0.0
#endregion

#region Processing Functions
## Validates that [member data] and [member target] are assigned.
func start() -> void:
	if data == null:
		push_error("OrbitComponent2D: No data assigned.")
		return

	if target == null:
		push_error("OrbitComponent2D: No valid target to orbit.")
		return

## Advances the orbit angle and repositions [member Component2D.Entity] around [member target] each frame.
func update(delta : float) -> void:
	if target == null or data == null:
		return

	var angle_step : float = deg_to_rad(data.speed) * delta
	if data.orbit_direction == "Clockwise":
		current_angle += angle_step
	else:
		current_angle -= angle_step

	var orbit_angle : float = data.start_angle + current_angle
	var orbit_position : Vector2 = Vector2(
		target.global_position.x + cos(orbit_angle) * data.distance,
		target.global_position.y + sin(orbit_angle) * data.distance
	)

	Entity.global_position = orbit_position


## Unused lifecycle hook.
func physics_update(_deltat : float) -> void:
	# Put physics process logic here
	pass
#endregion
