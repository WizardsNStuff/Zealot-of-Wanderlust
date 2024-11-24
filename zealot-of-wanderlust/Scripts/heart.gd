extends Node2D
class_name Heart

@export var animated_heart_sprite : AnimatedSprite2D
@export var heart_animation_player : AnimationPlayer

func _ready() -> void:
	animated_heart_sprite.play("heart_spin")
	heart_animation_player.play("heart_spring")
