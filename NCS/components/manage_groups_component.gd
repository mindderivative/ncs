class_name ManageGroupsComponent extends Component

#region Export Variables

@export var data : ManageGroupsComponentData # Base component data, change to component specific data type

#endregion

#region Variables

#endregion

#region Processing Functions
func start() -> void:
	# put ready logic here
	if !Entity:
		return
	
	add_remove()

func update(_delta : float) -> void:
	# Put process logic here
	pass

func physics_update(_deltat : float) -> void:
	# Put physics process logic here
	pass
#endregion

#region Component Functions
func add_remove() -> void:
	if !data:
		return
	
	for group in data.groups:
		var add : bool = data.groups[group]
		if add and !Entity.is_in_group(group):
			Entity.add_to_group(group)
		
		if !add and Entity.is_in_group(group):
			Entity.remove_from_group(group)
			
#endregion
