class_name RotateComponent3D extends Component3D

@export var rotate_data : RotateComponentData

var r : float

func _ready() -> void:
	super._ready()

func _process(delta: float) -> void:
	if !Enabled or !Entity:
		return

	update(delta)

func update(delta : float) -> void:
	r = deg_to_rad(rotate_data.rotation_speed) * delta
	
	if rotate_data.rotation_direction == "Clockwise":
		Entity.rotate_y(r)
	else:
		Entity.rotate_y(-r)
