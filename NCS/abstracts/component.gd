@abstract class_name Component extends Node

@export var Enabled : bool = true
var Entity : Node

## Stores the parent node as [member Entity] and calls [method start].
func _ready() -> void:
	var parent : Node = get_parent()
	if !parent:
		push_warning("No parent node.")

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
@abstract func physics_update(deltat : float) -> void
