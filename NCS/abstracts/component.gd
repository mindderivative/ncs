@abstract class_name Component extends Node

@export var Enabled : bool = true
var Entity : Node

func _ready() -> void:
	var parent : Node = get_parent()
	if !parent:
		push_warning("No parent node.")

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
