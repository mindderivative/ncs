class_name TileHighlightComponent2D
extends Component2D

signal refresh_requested()
signal tile_modulate_changed(cell : Vector2i, color: Color)
signal tile_modulate_cleared(cell : Vector2i)
signal tile_modulates_cleared()

const DEFAULT_MODULATE : Color = Color(1.0, 1.0, 1.0, 1.0)

## If checked, uses the parent Entity's modulate as the default modulate for tiles. If unchecked, uses the default_modulate color defined in this component. If the parent Entity is not a CanvasItem, will fall back to using default_modulate.
@export var use_parent : bool = false
## The default modulate color when not using parent modulate or when parent is not a CanvasItem
@export var default_modulate : Color = DEFAULT_MODULATE

var _cell_modulates : Dictionary[Vector2i, Color] = {}

## Returns [code]true[/code] if [param cell] has an explicit color override stored.
func has_modulate(cell : Vector2i) -> bool:
	return _cell_modulates.has(cell)


## Stores a color override for [param cell] and emits refresh and change signals.
func set_tile_modulate(cell : Vector2i, color : Color) -> void:
	_cell_modulates[cell] = color
	refresh_requested.emit()
	tile_modulate_changed.emit(cell, color)


## Snapshots the parent [CanvasItem] modulate if [member use_parent] is set, then triggers an initial runtime tile update.
func start() -> void:
	if not use_parent and default_modulate == DEFAULT_MODULATE and _cell_modulates.is_empty():
		return

	if use_parent:
		var parent_canvas_item : CanvasItem = Entity as CanvasItem
		if parent_canvas_item != null:
			default_modulate = parent_canvas_item.modulate

	refresh_requested.emit()


## Unused lifecycle hook.
func update(_delta : float) -> void:
	pass


## Unused lifecycle hook.
func physics_update(_deltat : float) -> void:
	pass


## Stores the same color override for all [param cells] and emits change signals for each.
func set_tiles_modulate(cells : Array[Vector2i], color : Color) -> void:
	if cells.is_empty():
		return

	for cell: Vector2i in cells:
		_cell_modulates[cell] = color

	refresh_requested.emit()

	for cell: Vector2i in cells:
		tile_modulate_changed.emit(cell, color)


## Removes the color override for [param cell] and emits [signal tile_modulate_cleared].
func clear_tile_modulate(cell : Vector2i) -> void:
	if not _cell_modulates.has(cell):
		return

	_cell_modulates.erase(cell)
	refresh_requested.emit()
	tile_modulate_cleared.emit(cell)


## Removes all color overrides and emits [signal tile_modulates_cleared].
func clear_all_tile_modulates() -> void:
	if _cell_modulates.is_empty():
		return

	_cell_modulates.clear()
	refresh_requested.emit()
	tile_modulates_cleared.emit()


## Returns [code]true[/code] if [param cell] requires a runtime tile data update.
func should_apply_runtime_update(cell : Vector2i) -> bool:
	return use_parent or _cell_modulates.has(cell) or default_modulate != DEFAULT_MODULATE


## Returns the effective default modulate; reads from the parent [CanvasItem] if [member use_parent] is set.
func get_default_modulate() -> Color:
	if not use_parent:
		return default_modulate

	var parent_canvas_item : CanvasItem = Entity as CanvasItem
	if parent_canvas_item != null:
		return parent_canvas_item.modulate

	return default_modulate


## Returns the stored color override for [param cell], or the default modulate if none is set.
func get_tile_modulate(cell : Vector2i) -> Color:
	return _cell_modulates.get(cell, get_default_modulate())
