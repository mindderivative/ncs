class_name MoveComponent2D extends Component2D

#region Signals
signal target_changed(Vector2)
#endregion

#region Export Variables
@export var data : MoveComponent2DData # Base component data, change to component specific data type
#endregion

#region Variables
var target_index : int = 0
var start_pos : Vector2
var segment_progress : float = 0.0
var segment_duration : float = 0.0
#endregion

#region Processing Functions
func start() -> void:
	# put ready logic here
	if data.path.size() > 0:
		setup_next_segment()

func update(_delta : float) -> void:
	# Put process logic here
	if target_index >= data.path.size():
		return
	
	move_to_target(data.path[target_index])

func physics_update(_delta : float) -> void:
	# Put physics process logic here
	pass
#endregion

#region Component Functions
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

func set_targets(targets : Array[Node2D]) -> void:
	if targets.size() <= 0:
		return
	
	for i in range(targets.size()):
		data.path.append(targets[i].global_position)

func setup_next_segment() -> void:
	if target_index < data.path.size():
		start_pos = Entity.global_position
		var distance = start_pos.distance_to(data.path[target_index])
		target_changed.emit(data.path[target_index])
		print("Signal emitted to signal: target_changed")
		
		segment_duration = distance / data.speed if distance > 0 else 0.01
		segment_progress = 0.0
#endregion
