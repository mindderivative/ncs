@abstract class_name Component3D extends Node3D

@export var Enabled : bool = true
var Entity : Node3D

## Validates the parent is a [Node3D], stores it as [member Entity], and calls [method start].
func _ready() -> void:
	var parent : Node = get_parent()
	if !parent:
		push_warning("No parent node.")
	if !parent is Node3D:
		push_error("Parent node must be of type Node3D.")
		return
	Entity = parent
	start()

## Calls [method update] every frame when [member Enabled] is [code]true[/code] and [member Entity] is valid.
func _process(delta: float) -> void:
	if !Enabled or !Entity:
		return

	update(delta)

## Calls [method physics_update] every physics frame when [member Enabled] is [code]true[/code] and [member Entity] is valid.
func _physics_process(delta : float) -> void:
	if !Enabled or !Entity:
		return

	physics_update(delta)

## Called once at startup. Override to initialize component state.
@abstract func start() -> void

## Called every process frame. Override to implement per-frame logic.
@abstract func update(delta : float) -> void

## Called every physics frame. Override to implement physics-driven logic.
@abstract func physics_update(delta : float) -> void
