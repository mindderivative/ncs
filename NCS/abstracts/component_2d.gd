@abstract class_name Component2D extends Node2D

@export var Enabled : bool = true
var Entity : Node2D

func _ready() -> void:
	var parent : Node = get_parent()
	if !parent:
		push_warning("No parent node.")
	if !parent is Node2D:
		push_error("Parent node must be of type Node2D.")
		return
	Entity = parent
	start()

func _process(delta: float) -> void:
	if !Enabled or !Entity:
		return

	update(delta)

func _physics_process(delta : float) -> void:
	if !Enabled or !Entity:
		return

	physics_update(delta)

@abstract func start() -> void

@abstract func update(delta : float) -> void

@abstract func physics_update(deltat : float) -> void
