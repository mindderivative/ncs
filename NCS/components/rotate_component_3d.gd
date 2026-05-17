class_name RotateComponent3D extends Component3D

#region Export Variables
## Component-specific data configuration for rotation speed and direction.
@export var data : RotateComponentData
#endregion

#region Variables
#endregion

#region Processing Functions
## Validates that [member data] is assigned.
func start() -> void:
	if data == null:
		push_error("RotateComponent3D: No data assigned.")
		return

## Rotates [member Component3D.Entity] around its Y axis by the configured speed and direction each frame.
func update(delta : float) -> void:
	if data == null:
		return

	var rotation_amount : float = deg_to_rad(data.rotation_speed) * delta
	
	if data.rotation_direction == "Clockwise":
		Entity.rotate_y(rotation_amount)
	else:
		Entity.rotate_y(-rotation_amount)


## Unused lifecycle hook.
func physics_update(_deltat : float) -> void:
	# Put physics process logic here
	pass
#endregion
