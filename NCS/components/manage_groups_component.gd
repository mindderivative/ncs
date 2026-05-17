class_name ManageGroupsComponent extends Component

#region Export Variables

## Component-specific data that specifies which groups to add or remove the Entity from.
@export var data : ManageGroupsComponentData

#endregion

#region Variables

#endregion

#region Processing Functions
## Validates [member data] and applies the initial group membership via [method add_remove].
func start() -> void:
	if data == null:
		push_error("ManageGroupsComponent: No data assigned.")
		return

	add_remove()


## Unused lifecycle hook.
func update(_delta : float) -> void:
	pass


## Unused lifecycle hook.
func physics_update(_deltat : float) -> void:
	pass
#endregion

#region Component Functions
## Adds or removes [member Component.Entity] from each group defined in [member ManageGroupsComponentData.groups].
func add_remove() -> void:
	if data == null:
		return

	for group : StringName in data.groups:
		var should_add : bool = data.groups[group]
		if should_add and not Entity.is_in_group(group):
			Entity.add_to_group(group)
		elif not should_add and Entity.is_in_group(group):
			Entity.remove_from_group(group)
#endregion
