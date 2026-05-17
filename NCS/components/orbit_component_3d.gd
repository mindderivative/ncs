class_name OrbitComponent3D extends Component3D

#region Export Variables
## Component-specific data configuration for orbit speed, distance, and direction.
@export var data : OrbitComponentData
## The Node3D around which to orbit.
@export var target : Node3D
#endregion

#region Variables
var current_angle : float = 0.0
#endregion

#region Processing Functions
## Validates that [member data] and [member target] are assigned.
func start() -> void:
	if data == null:
		push_error("OrbitComponent3D: No data assigned.")
		return

	if target == null:
		push_error("OrbitComponent3D: No valid target to orbit.")
		return

## Advances the orbit angle and repositions [member Component3D.Entity] around [member target] in the XZ plane each frame.
func update(delta : float) -> void:
	if target == null or data == null:
		return

	var angle_step : float = deg_to_rad(data.speed) * delta
	if data.orbit_direction == "Clockwise":
		current_angle += angle_step
	else:
		current_angle -= angle_step

	var orbit_angle : float = data.start_angle + current_angle
	var orbit_position : Vector3 = Vector3(
		target.global_position.x + cos(orbit_angle) * data.distance,
		target.global_position.y,
		target.global_position.z + sin(orbit_angle) * data.distance
	)

	Entity.global_position = orbit_position


## Unused lifecycle hook.
func physics_update(_deltat : float) -> void:
	# Put physics process logic here
	pass
#endregion
