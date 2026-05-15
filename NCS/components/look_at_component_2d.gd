class_name LookAtComponent2D extends Component2D

#region Export Variables
#@export var data : Data # Base component data, change to component specific data type
@export var data : LookAtComponent2DData
@export var target : Vector2

@export_group("Listening")
@export var emitters : Array[Node] = []

#endregion

#region Variables

#endregion

#region Processing Functions
func start() -> void:
	# put ready logic here
	
	call_deferred("get_entity")
	call_deferred("get_emitters")

func update(delta : float) -> void:
		
	Entity.look_at(target)


func physics_update(deltat : float) -> void:
	# Put physics process logic here
	pass
#endregion

#region Component Functions
func get_entity() -> void:
	if !data.look_at_entity and !data.entity_group:
		return

	var entity : Node2D = get_tree().get_first_node_in_group(data.entity_group)
		
	if !entity:
		push_warning("No Entity found in" + data.entity_group + "group.")
		return
		
	target = entity.global_position

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
				emitter.connect(signal_name, _on_target_changed)
				print("Connected to signal: " + signal_name)

func _on_target_changed(target_pos : Vector2) -> void:
	target = target_pos
#endregion
