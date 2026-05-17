class_name TileTransitionComponent2D
extends Component2D

## Animates per-cell color transitions on a TileHighlightComponent2D.
## Wire highlight_component in _ready() or via HexTileLayer2D.
#region Exports
## Default duration in seconds for color transition tweens.
@export var default_duration : float = 0.25
## The transition type (easing function) used for color animations.
@export var trans_type : Tween.TransitionType = Tween.TRANS_SINE
## The ease direction (in/out) applied to transitions.
@export var ease_type : Tween.EaseType = Tween.EASE_IN_OUT
#endregion

#region Signals
signal transition_finished(cell : Vector2i)
#endregion

#region Private Variables
var _highlight = null
var _tweens : Dictionary[Vector2i, Tween] = {}
#endregion

#region Public Methods
## Unused lifecycle hook.
func start() -> void:
	pass


## Unused lifecycle hook.
func update(_delta : float) -> void:
	pass


## Unused lifecycle hook.
func physics_update(_deltat : float) -> void:
	pass


## Injects the [TileHighlightComponent2D] dependency. Called by [HexTileLayer].
func set_highlight_component(highlight) -> void:
	_highlight = highlight


## Animates [param cell] from its current color to [param color] over [param duration] seconds.
func fade_in(cell : Vector2i, color : Color, duration : float = -1.0) -> void:
	if _highlight == null:
		return
	var dur : float = default_duration if duration < 0.0 else duration
	_cancel_tween(cell)
	var from : Color = _highlight.get_tile_modulate(cell)
	var tween : Tween = _make_tween(cell)
	tween.tween_method(_set_cell_color.bind(cell), from, color, dur)
	tween.finished.connect(_on_tween_done.bind(cell, tween), CONNECT_ONE_SHOT)


## Animates [param cell] from its current color back to the default modulate over [param duration] seconds.
func fade_out(cell : Vector2i, duration : float = -1.0) -> void:
	if _highlight == null:
		return
	var dur : float = default_duration if duration < 0.0 else duration
	_cancel_tween(cell)
	var from : Color = _highlight.get_tile_modulate(cell)
	var to : Color = _get_fade_out_target()
	var tween : Tween = _make_tween(cell)
	tween.tween_method(_set_cell_color.bind(cell), from, to, dur)
	tween.finished.connect(_on_tween_done_clear.bind(cell, tween), CONNECT_ONE_SHOT)


## Calls [method fade_in] on each cell in [param cells] simultaneously.
func fade_in_batch(cells : Array[Vector2i], color : Color, duration : float = -1.0) -> void:
	for cell : Vector2i in cells:
		fade_in(cell, color, duration)


## Calls [method fade_out] on each cell in [param cells] simultaneously.
func fade_out_batch(cells : Array[Vector2i], duration : float = -1.0) -> void:
	for cell : Vector2i in cells:
		fade_out(cell, duration)


## Kills the active tween for [param cell] without restoring its color.
func cancel(cell : Vector2i) -> void:
	_cancel_tween(cell)


## Kills all active tweens without restoring any cell colors.
func cancel_all() -> void:
	for cell : Vector2i in _tweens.keys():
		var tween : Tween = _tweens[cell]
		if tween != null and tween.is_valid():
			tween.kill()
	_tweens.clear()


## Returns [code]true[/code] if a tween is currently active for [param cell].
func is_transitioning(cell : Vector2i) -> bool:
	return _tweens.has(cell)
#endregion

#region Private Methods
## Creates and registers a new [Tween] for [param cell] with the configured easing settings.
func _make_tween(cell : Vector2i) -> Tween:
	var tween : Tween = get_tree().create_tween()
	tween.set_trans(trans_type)
	tween.set_ease(ease_type)
	_tweens[cell] = tween
	return tween


## Kills and removes the active tween for [param cell] if one exists.
func _cancel_tween(cell : Vector2i) -> void:
	if not _tweens.has(cell):
		return
	var existing : Tween = _tweens[cell]
	if existing != null and existing.is_valid():
		existing.kill()
	_tweens.erase(cell)


## Returns the color to tween toward on fade-out (the default modulate from the highlight component).
func _get_fade_out_target() -> Color:
	return _highlight.get_default_modulate()


## Tween callback: applies [param color] to [param cell] via the highlight component.
func _set_cell_color(color : Color, cell : Vector2i) -> void:
	if _highlight != null:
		_highlight.set_tile_modulate(cell, color)


## Called when a fade-in tween completes; removes [param cell] from the active tween registry.
func _on_tween_done(cell : Vector2i, tween : Tween) -> void:
	if _tweens.get(cell) == tween:
		_tweens.erase(cell)
	transition_finished.emit(cell)


## Called when a fade-out tween completes; clears the tile modulate and emits [signal transition_finished].
func _on_tween_done_clear(cell : Vector2i, tween : Tween) -> void:
	if _tweens.get(cell) == tween:
		_tweens.erase(cell)
	if _highlight != null:
		_highlight.clear_tile_modulate(cell)
	transition_finished.emit(cell)
#endregion