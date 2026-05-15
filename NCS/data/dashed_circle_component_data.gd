class_name DashedCircleComponentData extends Data

@export var radius : float = 100.0 :
	set(value):
		radius = value
		data_changed.emit()
@export var color : Color = Color("#ffffff59") :
	set(value):
			color = value
			data_changed.emit()
@export var width : float = 10.0 :
	set(value):
		width = value
		data_changed.emit()
@export var dash_length : float = 40.0 :
	set(value):
		dash_length = value
		data_changed.emit()
@export var gap_length : float = 20.0 :
	set(value):
		gap_length = value
		data_changed.emit()
