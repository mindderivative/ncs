class_name ObjectPoolingComponent extends Component
## Instantiates and manages an object pool.
##
## [PackedScene.instantiate()] a pre-determind amount of a [PackedScene], identified in the [ObjectPoolingComponentData] [Resource],
## into an [Array]. When an object is retrieved, the [Component] uses the [method Array.pop_front()] function then appends it
## to the end of the [Array], using the [method Array.append()] function, immediately.
##  

#region Export Variables
## Component-specific data that specifies the scene to pool and the quantity of instances to create.
@export var data : ObjectPoolingComponentData
## The internal array of pooled Node instances. Do not modify directly; managed by the component.
@export var object_pool : Array[Node] = []
#endregion

#region Variables
#endregion

#region Processing Functions
## Validates that [member data] and [member ObjectPoolingComponentData.scene] are assigned.
func start() -> void:
	if data == null:
		push_error("ObjectPoolingComponent: No data assigned.")
		return

	if data.scene == null:
		push_error("ObjectPoolingComponent: No scene assigned in data.")
		return


## Unused lifecycle hook.
func update(_delta : float) -> void:
	pass


## Unused lifecycle hook.
func physics_update(_deltat : float) -> void:
	pass
#endregion

#region Component Functions
## Pre-instantiates up to [member ObjectPoolingComponentData.max_object_count] objects into the pool.
func append_max_objects() -> void:
	if data == null or data.scene == null:
		return

	for _i : int in data.max_object_count:
		add_object()


## Returns the front object from the pool and rotates it to the back. Returns [code]null[/code] if the pool is empty.
func get_object() -> Node:
	if object_pool.is_empty():
		push_warning("ObjectPoolingComponent: Pool is empty. Call append_max_objects() first.")
		return null

	var obj : Node = object_pool.pop_front()
	object_pool.append(obj)
	return obj


## Instantiates one pooled object, disables it, and adds it as a child of [member Component.Entity].
func add_object() -> void:
	if data == null or data.scene == null:
		return

	var obj : Node = data.scene.instantiate()
	object_pool.append(obj)
	obj.set_process(false)
	obj.set_physics_process(false)
	obj.hide()
	Entity.add_child(obj, true)
#endregion
