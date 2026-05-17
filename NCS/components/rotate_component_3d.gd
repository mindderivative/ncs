class_name RotateComponent3D extends Component3D

#region Export Variables
@export var data : RotateComponentData
#endregion

#region Variables
var r : float
#endregion

#region Processing Functions
func start() -> void:
	# put ready logic here
	pass

func update(delta : float) -> void:
	r = deg_to_rad(data.rotation_speed) * delta
	
	if data.rotation_direction == "Clockwise":
		Entity.rotate_y(r)
	else:
		Entity.rotate_y(-r)

func physics_update(_deltat : float) -> void:
	# Put physics process logic here
	pass
#endregion
