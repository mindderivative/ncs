class_name SpawningComponent2D extends Component2D

#region Export Variables

## Component-specific data configuration for spawn behavior, interval, count, and randomization.
@export var data : SpawningComponentData
## Reference to the ObjectPoolingComponent that provides recycled objects for spawning.
@export var object_pool : ObjectPoolingComponent
#endregion

#region Variables
var _time_since_last_spawn : float = 0.0
var _cooldown_timer : float = 0.0
#endregion

#region Processing Functions
## Validates that [member data] and [member object_pool] are assigned.
func start() -> void:
	if data == null:
		push_error("SpawningComponent2D: No data assigned.")
		return

	if object_pool == null:
		push_error("SpawningComponent2D: No object pool assigned.")


## Ticks cooldown and auto-spawns at [member SpawningComponentData.spawn_interval] when interval is set.
func update(delta : float) -> void:
	if data == null or object_pool == null:
		return

	if _cooldown_timer > 0.0:
		_cooldown_timer -= delta

	if data.spawn_interval <= 0.0:
		return

	_time_since_last_spawn += delta
	if _time_since_last_spawn >= data.spawn_interval:
		spawn_object()
		_time_since_last_spawn = 0.0

## Unused lifecycle hook.
func physics_update(_deltat : float) -> void:
	# Put physics process logic here
	pass
#endregion

#region Component Functions
## Spawns a batch of objects from [member object_pool] at [member Component2D.Entity]'s position, with optional random region offset.
func spawn_object() -> void:
	if _cooldown_timer > 0.0 or data == null or object_pool == null:
		return

	_cooldown_timer = data.spawn_cooldown

	for _i : int in data.spawn_count:
		var obj : Node2D = object_pool.get_object()
		if obj == null:
			continue

		var spawn_pos : Vector2 = Entity.global_position
		if data.use_random_region:
			spawn_pos += Vector2(
				randf_range(data.spawn_region.position.x, data.spawn_region.end.x),
				randf_range(data.spawn_region.position.y, data.spawn_region.end.y)
			)

		obj.global_position = spawn_pos
		obj.set_process(true)
		obj.set_physics_process(true)
		obj.show()

# Trigger for external signals or manual calls
## Manually triggers a spawn; respects the active cooldown timer.
func trigger_spawn() -> void:
	spawn_object()
#endregion
