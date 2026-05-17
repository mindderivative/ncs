extends Sprite2D

@export var animation_player : AnimationPlayer
@export var animations : Array[String]

func _ready():
    for animation in animations:
        if animation_player.has_animation(animation): # Check if the animation exists
            animation_player.play(animation)
        else:
            push_warning("Animation '%s' not found in AnimationPlayer." % animation)