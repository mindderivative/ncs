class_name ObjectPoolingComponent extends Component
## Instantiates and manages an object pool.
##
## [PackedScene.instantiate()] a pre-determind amount of a [PackedScene], identified in the [ObjectPoolingComponentData] [Resource],
## into an [Array]. When an object is retrieved, the [Component] uses the [method Array.pop_front()] function then appends it
## to the end of the [Array], using the [method Array.append()] function, immediately.
##  

#region Export Variables
@export var data : ObjectPoolingComponentData 
@export var object_pool : Array[Node] = []
#endregion

#region Variables
#endregion

#region Processing Functions
func start() -> void:
	# put ready logic here
	pass

func update(delta : float) -> void:
	# Put process logic here
	pass

func physics_update(deltat : float) -> void:
	# Put physics process logic here
	pass
#endregion

#region Component Functions
func append_max_objects() -> void:
	for i in data.max_object_count:
		add_object()

func get_object() -> Node:
	if object_pool.size() > 0:
		var obj : Node = object_pool.pop_front()
		object_pool.append(obj)
		return obj
	return null

func add_object() -> void:
	var obj : Node = data.scene.instantiate()
	object_pool.append(obj)
	
	obj.set_process(false)
	obj.set_physics_process(false)
	obj.hide()
	Entity.add_child(obj, true)
#endregion
