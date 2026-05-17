class_name HexTileLayer
extends TileMapLayer

#region Signals
signal tile_modulate_changed(cell : Vector2i, color: Color)
signal tile_modulate_cleared(cell : Vector2i)
signal tile_modulates_cleared()
#endregion

#region Exports
@export var validate_hex_shape_on_ready : bool = true
@export var modulator : TileHighlightComponent2D
@export var transition : TileTransitionComponent2D

@export_group("Adjust Tile Alignment")
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var align_tiles : bool = true
@export var tile_alignment_offset : Vector2 = Vector2.ZERO
#endregion

#region Processing Overrides
## Wires signals from [member modulator] and [member transition], and validates the [TileSet] shape.
func _ready() -> void:
    if modulator != null:
        modulator.refresh_requested.connect(_on_refresh_requested)
        modulator.tile_modulate_changed.connect(_on_tile_modulate_changed)
        modulator.tile_modulate_cleared.connect(_on_tile_modulate_cleared)
        modulator.tile_modulates_cleared.connect(_on_tile_modulates_cleared)

    if transition != null and modulator != null:
        transition.set_highlight_component(modulator)

    if validate_hex_shape_on_ready and tile_set != null:
        if tile_set.tile_shape != TileSet.TILE_SHAPE_HEXAGON:
            push_warning("HexTileLayer expects a hex TileSet shape.")
#endregion

#region Tile Interaction Methods
## Fades [param cell] to [param color] over [param duration] seconds via the transition component, or sets it directly.
func fade_in_tile(cell: Vector2i, color: Color, duration: float = -1.0) -> void:
    if transition != null:
        transition.fade_in(cell, color, duration)
    elif modulator != null:
        modulator.set_tile_modulate(cell, color)


## Fades [param cell] back to the default modulate over [param duration] seconds via the transition component, or clears it directly.
func fade_out_tile(cell: Vector2i, duration: float = -1.0) -> void:
    if transition != null:
        transition.fade_out(cell, duration)
    elif modulator != null:
        modulator.clear_tile_modulate(cell)


## Fades all [param cells] to [param color] simultaneously.
func fade_in_tiles(cells: Array[Vector2i], color: Color, duration: float = -1.0) -> void:
    if transition != null:
        transition.fade_in_batch(cells, color, duration)
    elif modulator != null:
        modulator.set_tiles_modulate(cells, color)


## Fades all [param cells] back to the default modulate simultaneously.
func fade_out_tiles(cells: Array[Vector2i], duration: float = -1.0) -> void:
    if transition != null:
        transition.fade_out_batch(cells, duration)
    elif modulator != null:
        for cell: Vector2i in cells:
            modulator.clear_tile_modulate(cell)


## Returns [code]true[/code] if a color tween is currently running for [param cell].
func is_tile_transitioning(cell: Vector2i) -> bool:
    if transition == null:
        return false
    return transition.is_transitioning(cell)


## Returns the local-space center position of [param cell].
func get_tile_local_position(cell: Vector2i) -> Vector2:
    return map_to_local(cell)

## Returns the global-space center position of [param cell].
func get_tile_global_position(cell: Vector2i) -> Vector2:
    return to_global(map_to_local(cell))

## Converts a world-space position to tile map cell coordinates.
func world_to_cell(world_position: Vector2) -> Vector2i:
    return local_to_map(to_local(world_position))

## Returns [code]true[/code] if a tile exists at [param cell].
func has_tile(cell: Vector2i) -> bool:
    return get_cell_source_id(cell) != -1

## Returns the [TileData] for [param cell], or [code]null[/code] if none exists.
func get_tile_data(cell: Vector2i) -> TileData:
    var source_id: int = get_cell_source_id(cell)
    if source_id == -1:
        return null
    var source: TileSetSource = tile_set.get_source(source_id)
    if source == null:
        return null
    var atlas := source as TileSetAtlasSource
    if atlas == null:
        return null
    return atlas.get_tile_data(get_cell_atlas_coords(cell), get_cell_alternative_tile(cell))

## Returns the source ID for the tile at [param cell].
func get_tile_source_id(cell: Vector2i) -> int:
    return get_cell_source_id(cell)

## Returns the atlas coordinates for the tile at [param cell].
func get_tile_atlas_coords(cell: Vector2i) -> Vector2i:
    return get_cell_atlas_coords(cell)

## Returns the alternative tile ID for the tile at [param cell].
func get_tile_alternative_id(cell: Vector2i) -> int:
    return get_cell_alternative_tile(cell)

## Returns the value of a named custom data layer for the tile at [param cell].
func get_tile_custom_data(cell: Vector2i, layer_name: StringName) -> Variant:
    var td: TileData = get_tile_data(cell)
    if td == null:
        return null
    return td.get_custom_data(layer_name)

## Returns all used cell coordinates that fall within [param rect].
func get_tiles_in_rect(rect: Rect2i) -> Array[Vector2i]:
    var result: Array[Vector2i] = []
    for cell: Vector2i in get_used_cells():
        if rect.has_point(cell):
            result.append(cell)
    return result

## Sets a color override for [param cell] via the modulator component.
func set_tile_modulate(cell: Vector2i, color: Color) -> void:
    if modulator != null:
        modulator.set_tile_modulate(cell, color)

## Clears the color override for [param cell] via the modulator component.
func clear_tile_modulate(cell: Vector2i) -> void:
    if modulator != null:
        modulator.clear_tile_modulate(cell)

## Clears all color overrides via the modulator component.
func clear_all_tile_modulates() -> void:
    if modulator != null:
        modulator.clear_all_tile_modulates()

## Returns the color override for [param cell], or opaque white if none is set.
func get_tile_modulate(cell: Vector2i) -> Color:
    if modulator == null:
        return Color(1.0, 1.0, 1.0, 1.0)
    return modulator.get_tile_modulate(cell)

## Returns [code]true[/code] if [param cell] has a color override set.
func has_tile_modulate(cell: Vector2i) -> bool:
    if modulator == null:
        return false
    return modulator.has_modulate(cell)

## Engine callback: returns [code]true[/code] if [param coords] needs a per-frame tile data update.
func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
    return modulator != null and modulator.should_apply_runtime_update(coords)

## Engine callback: applies the stored modulate color to [param tile_data] at runtime.
func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData) -> void:
    if modulator == null:
        return
    tile_data.modulate = modulator.get_tile_modulate(coords)

## Forces a full tile data runtime update sweep on the next frame.
func _on_refresh_requested() -> void:
    notify_runtime_tile_data_update()

## Re-emits [signal tile_modulate_changed] from the modulator.
func _on_tile_modulate_changed(cell: Vector2i, color: Color) -> void:
    tile_modulate_changed.emit(cell, color)

## Re-emits [signal tile_modulate_cleared] from the modulator.
func _on_tile_modulate_cleared(cell: Vector2i) -> void:
    tile_modulate_cleared.emit(cell)

## Re-emits [signal tile_modulates_cleared] from the modulator.
func _on_tile_modulates_cleared() -> void:
    tile_modulates_cleared.emit()
#endregion

#region Tile Layer Interaction Methods
## Applies [member tile_alignment_offset] to the layer position. Only runs if [member align_tiles] is enabled.
func set_tile_layer_position() -> void:
    if not align_tiles:
        return
    position = tile_alignment_offset