class_name OrbitComponent2D extends Component2D

#region Export Variables
@export var data : OrbitComponentData # Base component data, change to component specific data type
@export var target : Node2D
#endregion

#region Variables
var current_angle : float = 0.0
var x : float = 0.0
var y : float = 0.0
#endregion

#region Processing Functions
func start() -> void:
	
	pass

func update(delta : float) -> void:
	if !target:
		push_error("No valid target to orbit.")
		return
	
	if data.orbit_direction == "Clockwise":
		current_angle += deg_to_rad(data.speed) * delta
	else:
		current_angle -= deg_to_rad(data.speed) * delta

	x = target.global_position.x + cos(data.start_angle + current_angle) * data.distance
	y = target.global_position.y + sin(data.start_angle + current_angle) * data.distance
	
	Entity.position = Vector2(x, y)

func physics_update(_deltat : float) -> void:
	# Put physics process logic here
	pass
#endregion
