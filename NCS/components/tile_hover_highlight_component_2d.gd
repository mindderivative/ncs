class_name TileHoverHighlightComponent2D
extends Component2D

signal hover_cell_changed(previous_cell: Vector2i, current_cell: Vector2i)
signal hover_cleared(cell: Vector2i)

## The HexTileLayer on which to apply hover highlights. Auto-detected from Entity if not assigned.
@export var tile_layer: HexTileLayer
## The ring radius (in cells) to highlight when hovering over a tile.
@export_range(1, 32, 1) var hover_range: int = 1
## The color to apply to hovered tiles during the fade-in.
@export var hover_color: Color = Color(1.0, 1.0, 0.4, 0.8)
## Duration in seconds for the hover highlight fade-in animation.
@export var hover_fade_duration: float = 0.12
## Duration in seconds for the hover highlight fade-out animation.
@export var unhover_fade_duration: float = 0.12
## If true, clears all hover highlights when the mouse leaves the tile layer.
@export var clear_highlight_on_exit: bool = true

var _is_hovering: bool = false
var _hovered_center_cell: Vector2i = Vector2i.ZERO
var _last_applied_hover_range: int = 1
var _active_hover_cells: Dictionary[Vector2i, bool] = {}
var _cell_previous_colors: Dictionary[Vector2i, Color] = {}
var _cell_had_previous_modulate: Dictionary[Vector2i, bool] = {}


## Auto-detects [member tile_layer] from [member Component2D.Entity] if not assigned, and wires the transition finished signal.
func start() -> void:
	if tile_layer == null:
		tile_layer = Entity as HexTileLayer

	if tile_layer != null and tile_layer.transition != null:
		if not tile_layer.transition.transition_finished.is_connected(_on_transition_finished):
			tile_layer.transition.transition_finished.connect(_on_transition_finished)


## Tracks the mouse position and updates the hovered cell ring each frame.
func update(_delta: float) -> void:
	if tile_layer == null:
		return

	var mouse_world_position: Vector2 = tile_layer.get_global_mouse_position()
	var current_cell: Vector2i = tile_layer.world_to_cell(mouse_world_position)
	var has_cell: bool = tile_layer.has_tile(current_cell)

	if not has_cell:
		if _is_hovering:
			var cleared_cell: Vector2i = _hovered_center_cell
			_clear_hover_cells()
			hover_cleared.emit(cleared_cell)
		return

	var normalized_hover_range: int = max(1, hover_range)
	var target_hover_cells: Array[Vector2i] = _get_hover_cells(current_cell, normalized_hover_range)

	if _is_hovering and current_cell == _hovered_center_cell and normalized_hover_range == _last_applied_hover_range:
		return

	var previous_cell: Vector2i = _hovered_center_cell if _is_hovering else current_cell
	_update_hover_cells(target_hover_cells)
	_hovered_center_cell = current_cell
	_last_applied_hover_range = normalized_hover_range
	_is_hovering = true
	hover_cell_changed.emit(previous_cell, current_cell)


## Unused lifecycle hook.
func physics_update(_deltat: float) -> void:
	pass


## Clears all hover highlights when this component leaves the scene tree.
func _exit_tree() -> void:
	if clear_highlight_on_exit:
		_clear_hover_cells()


## Diffs the previous and target cell sets, calling begin-hover or begin-restore for each changed cell.
func _update_hover_cells(target_hover_cells: Array[Vector2i]) -> void:
	var target_hover_cell_set: Dictionary[Vector2i, bool] = {}
	for cell: Vector2i in target_hover_cells:
		target_hover_cell_set[cell] = true

	for cell_variant in _active_hover_cells.keys():
		var cell: Vector2i = cell_variant
		if target_hover_cell_set.has(cell):
			continue
		_begin_restore_hover_cell(cell)
		_active_hover_cells.erase(cell)

	for cell: Vector2i in target_hover_cells:
		if _active_hover_cells.has(cell):
			continue
		_begin_hover_cell(cell)
		_active_hover_cells[cell] = true


## Snapshots the cell's current color and starts the hover fade-in.
func _begin_hover_cell(cell: Vector2i) -> void:
	if tile_layer.transition != null:
		tile_layer.transition.cancel(cell)

	if not _cell_previous_colors.has(cell):
		_cell_had_previous_modulate[cell] = tile_layer.has_tile_modulate(cell)
		_cell_previous_colors[cell] = tile_layer.get_tile_modulate(cell)

	tile_layer.fade_in_tile(cell, hover_color, hover_fade_duration)


## Restores a cell to its pre-hover color using the appropriate fade direction.
func _begin_restore_hover_cell(cell: Vector2i) -> void:
	var has_transition: bool = tile_layer.transition != null
	if has_transition:
		tile_layer.transition.cancel(cell)

	if _cell_had_previous_modulate.get(cell, false):
		tile_layer.fade_in_tile(cell, _cell_previous_colors[cell], unhover_fade_duration)
	else:
		tile_layer.fade_out_tile(cell, unhover_fade_duration)

	if not has_transition:
		_cell_previous_colors.erase(cell)
		_cell_had_previous_modulate.erase(cell)


## Restores all currently hovered cells and resets all hover state.
func _clear_hover_cells() -> void:
	if _active_hover_cells.is_empty():
		_is_hovering = false
		_hovered_center_cell = Vector2i.ZERO
		_last_applied_hover_range = max(1, hover_range)
		return

	for cell_variant in _active_hover_cells.keys():
		var cell: Vector2i = cell_variant
		_begin_restore_hover_cell(cell)

	_active_hover_cells.clear()
	_is_hovering = false
	_hovered_center_cell = Vector2i.ZERO
	_last_applied_hover_range = max(1, hover_range)


## BFS-expands a ring of valid tiles around [param center] up to [param hover_ring_count] rings deep.
func _get_hover_cells(center: Vector2i, hover_ring_count: int) -> Array[Vector2i]:
	var hover_cells: Dictionary[Vector2i, bool] = {}
	hover_cells[center] = true

	var frontier: Array[Vector2i] = [center]
	for _ring_index: int in range(1, hover_ring_count):
		if frontier.is_empty():
			break

		var next_frontier: Array[Vector2i] = []
		for cell: Vector2i in frontier:
			for neighbor: Vector2i in tile_layer.get_surrounding_cells(cell):
				if hover_cells.has(neighbor):
					continue
				if not tile_layer.has_tile(neighbor):
					continue
				hover_cells[neighbor] = true
				next_frontier.append(neighbor)

		frontier = next_frontier

	var result: Array[Vector2i] = []
	for cell_variant in hover_cells.keys():
		result.append(cell_variant)
	return result


## Cleans up snapshot state for cells that have finished their restore tween.
func _on_transition_finished(cell: Vector2i) -> void:
	if _active_hover_cells.has(cell):
		return

	_cell_previous_colors.erase(cell)
	_cell_had_previous_modulate.erase(cell)
