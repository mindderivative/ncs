extends Node
class_name TileHighlightComponent2D

signal refresh_requested()
signal tile_modulate_changed(cell: Vector2i, color: Color)
signal tile_modulate_cleared(cell: Vector2i)
signal tile_modulates_cleared()

@export var default_modulate: Color = Color(1.0, 1.0, 1.0, 1.0)

var _cell_modulates: Dictionary[Vector2i, Color] = {}

func has_modulate(cell: Vector2i) -> bool:
    return _cell_modulates.has(cell)

func set_tile_modulate(cell: Vector2i, color: Color) -> void:
    _cell_modulates[cell] = color
    refresh_requested.emit()
    tile_modulate_changed.emit(cell, color)

func set_tiles_modulate(cells: Array[Vector2i], color: Color) -> void:
    if cells.is_empty():
        return

    for cell: Vector2i in cells:
        _cell_modulates[cell] = color

    refresh_requested.emit()

    for cell: Vector2i in cells:
        tile_modulate_changed.emit(cell, color)

func clear_tile_modulate(cell: Vector2i) -> void:
    if not _cell_modulates.has(cell):
        return

    _cell_modulates.erase(cell)
    refresh_requested.emit()
    tile_modulate_cleared.emit(cell)

func clear_all_tile_modulates() -> void:
    if _cell_modulates.is_empty():
        return

    _cell_modulates.clear()
    refresh_requested.emit()
    tile_modulates_cleared.emit()

func get_tile_modulate(cell: Vector2i) -> Color:
    return _cell_modulates.get(cell, default_modulate)