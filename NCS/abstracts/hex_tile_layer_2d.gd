extends TileMapLayer
class_name HexTileLayer2D

signal tile_modulate_changed(cell: Vector2i, color: Color)
signal tile_modulate_cleared(cell: Vector2i)
signal tile_modulates_cleared()

@export var validate_hex_shape_on_ready: bool = true
@export var modulator_path: NodePath

var _modulator: TileHighlightComponent2D

func _ready() -> void:
    _resolve_modulator()

    if validate_hex_shape_on_ready and tile_set != null:
        if tile_set.tile_shape != TileSet.TILE_SHAPE_HEXAGON:
            push_warning("HexTileLayer2D expects a hex TileSet shape.")

func _resolve_modulator() -> void:
    if modulator_path.is_empty():
        _modulator = null
        return

    _modulator = get_node_or_null(modulator_path) as TileHighlightComponent2D
    if _modulator == null:
        push_warning("HexTileLayer2D could not resolve TileHighlightComponent2D from modulator_path.")
        return

    if not _modulator.refresh_requested.is_connected(_on_refresh_requested):
        _modulator.refresh_requested.connect(_on_refresh_requested)
    if not _modulator.tile_modulate_changed.is_connected(_on_tile_modulate_changed):
        _modulator.tile_modulate_changed.connect(_on_tile_modulate_changed)
    if not _modulator.tile_modulate_cleared.is_connected(_on_tile_modulate_cleared):
        _modulator.tile_modulate_cleared.connect(_on_tile_modulate_cleared)
    if not _modulator.tile_modulates_cleared.is_connected(_on_tile_modulates_cleared):
        _modulator.tile_modulates_cleared.connect(_on_tile_modulates_cleared)

func get_tile_local_position(cell: Vector2i) -> Vector2:
    return map_to_local(cell)

func get_tile_global_position(cell: Vector2i) -> Vector2:
    return to_global(map_to_local(cell))

func world_to_cell(world_position: Vector2) -> Vector2i:
    return local_to_map(to_local(world_position))

func has_tile(cell: Vector2i) -> bool:
    return get_cell_source_id(cell) != -1

func set_tile_modulate(cell: Vector2i, color: Color) -> void:
    if _modulator != null:
        _modulator.set_tile_modulate(cell, color)

func clear_tile_modulate(cell: Vector2i) -> void:
    if _modulator != null:
        _modulator.clear_tile_modulate(cell)

func clear_all_tile_modulates() -> void:
    if _modulator != null:
        _modulator.clear_all_tile_modulates()

func get_tile_modulate(cell: Vector2i) -> Color:
    if _modulator == null:
        return Color(1.0, 1.0, 1.0, 1.0)
    return _modulator.get_tile_modulate(cell)

func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
    return _modulator != null and _modulator.has_modulate(coords)

func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData) -> void:
    if _modulator == null:
        return
    tile_data.modulate = _modulator.get_tile_modulate(coords)

func _on_refresh_requested() -> void:
    notify_runtime_tile_data_update()

func _on_tile_modulate_changed(cell: Vector2i, color: Color) -> void:
    tile_modulate_changed.emit(cell, color)

func _on_tile_modulate_cleared(cell: Vector2i) -> void:
    tile_modulate_cleared.emit(cell)

func _on_tile_modulates_cleared() -> void:
    tile_modulates_cleared.emit()