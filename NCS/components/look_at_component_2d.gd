class_name LookAtComponent2D extends Component2D

#region Export Variables
## Component-specific data configuration for look-at behavior.
@export var data : LookAtComponent2DData
## The world position to face. The Entity will continuously rotate to look at this point.
@export var target : Vector2

@export_group("Listening")
## Array of Nodes that emit signals to trigger target updates.
@export var emitters : Array[Node] = []

#endregion

#region Variables

#endregion

#region Processing Functions
## Defers entity group lookup and emitter signal wiring until the scene tree is ready.
func start() -> void:
	# put ready logic here
	
	call_deferred("get_entity")
	call_deferred("get_emitters")


## Rotates [member Component2D.Entity] to face [member target] each frame.
func update(_delta : float) -> void:
		
	Entity.look_at(target)



## Unused lifecycle hook.
func physics_update(_deltat : float) -> void:
	# Put physics process logic here
	pass
#endregion

#region Component Functions
## Finds the first node in [member LookAtComponent2DData.entity_group] and sets its position as [member target].
func get_entity() -> void:
	if !data.look_at_entity and !data.entity_group:
		return

	var entity : Node2D = get_tree().get_first_node_in_group(data.entity_group)
		
	if !entity:
		push_warning("No Entity found in %s group." % data.entity_group)
		return
		
	target = entity.global_position


## Connects to [code]target_changed[/code] signals from all nodes in [member emitters].
func get_emitters() -> void:
	if data.look_at_entity and data.entity_group:
		return
	if emitters.is_empty():
		return
	
	for emitter in emitters:
		var signals : Array = emitter.get_signal_list()
		for s in signals:
			var signal_name = s["name"]
			
			if signal_name == "target_changed":
				var target_changed_callable : Callable = Callable(self, "_on_target_changed")
				if not emitter.is_connected(signal_name, target_changed_callable):
					emitter.connect(signal_name, target_changed_callable)


## Updates [member target] when an emitter fires the [code]target_changed[/code] signal.
func _on_target_changed(target_pos : Vector2) -> void:
	target = target_pos
#endregion
