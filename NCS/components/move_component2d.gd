class_name MoveComponent2D extends Component2D

#region Signals
signal target_changed(Vector2)
#endregion

#region Export Variables
## Component-specific data that defines the movement path, speed, and interpolation settings.
@export var data : MoveComponent2DData
#endregion

#region Variables
var target_index : int = 0
var start_pos : Vector2
var segment_progress : float = 0.0
var segment_duration : float = 0.0
#endregion

#region Processing Functions
## Validates [member data] and speed, then kicks off the first path segment via [method setup_next_segment].
func start() -> void:
	# put ready logic here
	if data == null:
		push_error("MoveComponent2D: No data assigned.")
		return

	if data.speed <= 0.0:
		push_error("MoveComponent2D: speed must be greater than 0.")
		return

	if data.path.size() > 0:
		setup_next_segment()

## Advances [member Component2D.Entity] along the current path segment each frame.
func update(_delta : float) -> void:
	# Put process logic here
	if target_index >= data.path.size():
		return
	
	move_to_target(data.path[target_index])


## Unused lifecycle hook.
func physics_update(_delta : float) -> void:
	# Put physics process logic here
	pass
#endregion

#region Component Functions
## Lerps [member Component2D.Entity] toward [param target]; advances to the next waypoint on arrival.
func move_to_target(target : Vector2) -> void:
	#var direction = (target - Entity.global_position).normalized()
	#
	#Entity.global_position += direction * data.speed * get_process_delta_time()
	#
	#if Entity.global_position.distance_squared_to(target) < data.stop_distant:
		#target_index += 1
	
	segment_progress += get_process_delta_time() / segment_duration
	
	Entity.global_position = start_pos.lerp(target, segment_progress)
	var distance_left = Entity.global_position.distance_squared_to(target)
	
	if distance_left <= data.stop_distant or segment_progress >= 1.0:
		target_index += 1
		setup_next_segment()


## Appends the global positions of [param targets] nodes to [member MoveComponent2DData.path].
func set_targets(targets : Array[Node2D]) -> void:
	if targets.size() <= 0:
		return
	
	for i in range(targets.size()):
		data.path.append(targets[i].global_position)


## Prepares lerp start position and duration for the next path waypoint.
func setup_next_segment() -> void:
	if data == null:
		return

	if data.speed <= 0.0:
		push_error("MoveComponent2D: speed must be greater than 0.")
		return

	if target_index < data.path.size():
		start_pos = Entity.global_position
		var distance = start_pos.distance_to(data.path[target_index])
		target_changed.emit(data.path[target_index])
		
		segment_duration = distance / data.speed if distance > 0 else 0.01
		segment_progress = 0.0
#endregion
