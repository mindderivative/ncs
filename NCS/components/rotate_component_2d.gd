class_name RotateComponent2D extends Component2D

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
		Entity.rotate(r)
	else:
		Entity.rotate(-r)

func physics_update(deltat : float) -> void:
	# Put physics process logic here
	pass
#endregion
