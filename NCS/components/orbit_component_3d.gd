class_name OrbitComponent3D extends Component3D

#region Export Variables
@export var data : OrbitComponentData # Base component data, change to component specific data type
@export var target : Node3D
#endregion

#region Variables
var current_angle : float = 0.0
var x : float = 0.0
var y : float = 0.0
var z : float = 0.0
#endregion

#region Processing Functions
func start() -> void:
	# put ready logic here
	pass

func update(delta : float) -> void:
	if !target:
		push_error("No valid target to orbit")
		return
	
	if data.orbit_direction == "Clockwise":
		current_angle += deg_to_rad(data.speed) * delta
	else:
		current_angle -= deg_to_rad(data.speed) * delta
	
	x = target.global_position.x + cos(data.start_angle + current_angle) * data.distance
	z = target.global_position.z + sin(data.start_angle + current_angle) * data.distance
	
	Entity.global_position = Vector3(x, target.global_position.y, z)

func physics_update(deltat : float) -> void:
	# Put physics process logic here
	pass
#endregion
