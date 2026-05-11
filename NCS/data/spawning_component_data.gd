class_name SpawningComponentData extends Data

@export_group("Spawn Settings")
@export var spawn_count : int = 1
@export var spawn_rate : float = 1.0 # Spawns per second
@export var spawn_interval : float = 1.0 # Secons between automated spawns
@export var spawn_cooldown : float = 1.0 # Minimum time between manual triggers

@export_group("Location Settings")
@export var use_random_region : bool = false
@export var spawn_region : Rect2 = Rect2(0,0,100,100) # Local to Entity
