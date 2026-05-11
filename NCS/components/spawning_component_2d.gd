class_name SpawningComponent2D extends Component2D

#region Export Variables

@export var data : SpawningComponentData # Base component data, change to component specific data type
@export var object_pool : ObjectPoolingComponent # instead of a direct reference maybe a signal?
#endregion

#region Variables
var x : float = 0.0
var y : float = 0.0
var _time_since_last_spawn : float = 0.0
var _cooldown_timer : float = 0.0
#endregion

#region Processing Functions
func start() -> void:
	if !object_pool:
		push_error("SpawningComponent2D: No object pool assigned.")

func update(delta : float) -> void:
	# Handle Cooldown
	if _cooldown_timer > 0:
		_cooldown_timer -= delta
	
	# Handle Automated Interval Spawning
	_time_since_last_spawn += delta
	if data.spawn_interval > 0 and _time_since_last_spawn >= data.spawn_interval:
		spawn_object()
		_time_since_last_spawn = 0.0

func physics_update(deltat : float) -> void:
	# Put physics process logic here
	pass
#endregion

#region Component Functions
func spawn_object() -> void:
	# Prevent spawning if on cooldown or missing dependencies
	if _cooldown_timer > 0 or !object_pool or !data:
		return
	
	_cooldown_timer = data.spawn_cooldown
	
	for i in data.spawn_count:
		var obj : Node2D = object_pool.get_object()
		if !obj: continue
		
		# Determine spawn position
		var spawn_pos = Entity.global_position
		if data.use_random_region:
			var random_offset = Vector2(
				randf_range(data.spawn_region.position.x, data.spawn_region.end.x),
				randf_range(data.spawn_region.position.y, data.spawn_region.end.y)
			)
			spawn_pos += random_offset

		obj.global_position = spawn_pos
		
		# Reset object state
		obj.set_process(true)
		obj.set_physics_process(true)
		obj.show()

# Trigger for external signals or manual calls
func trigger_spawn() -> void:
	spawn_object()
#endregion
