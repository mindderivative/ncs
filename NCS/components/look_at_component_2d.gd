class_name LookAtComponent2D extends Component2D

#region Export Variables
#@export var data : Data # Base component data, change to component specific data type
@export var target : Node2D
#endregion

#region Variables

#endregion

#region Processing Functions
func start() -> void:
	# put ready logic here
	pass

func update(delta : float) -> void:
	if !target:
		push_error("No valid target to look at.")
		return
	
	Entity.look_at(target.global_position)

func physics_update(deltat : float) -> void:
	# Put physics process logic here
	pass
#endregion
