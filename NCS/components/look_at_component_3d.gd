class_name LookAtComponent3D extends Component3D

#region Export Variables
## The Node3D to face. The Entity will continuously rotate to look at this target.
@export var target : Node3D
#endregion

#region Variables

#endregion

#region Processing Functions
## Validates that [member target] is assigned.
func start() -> void:
	if target == null:
		push_error("LookAtComponent3D: No valid target to look at.")
		return


## Rotates [member Component3D.Entity] to face [member target] each frame using [method Node3D.look_at].
func update(_delta : float) -> void:
	if target == null:
		return
	
	Entity.look_at(target.global_position, Vector3.UP)


## Unused lifecycle hook.
func physics_update(_deltat : float) -> void:
	# Put physics process logic here
	pass
#endregion
