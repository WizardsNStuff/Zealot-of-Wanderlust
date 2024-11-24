extends Node2D
class_name Heart

@export var animated_heart_sprite : AnimatedSprite2D
@export var heart_animation_player : AnimationPlayer
@export var area_2d : Area2D
var controller

func _ready() -> void:
	animated_heart_sprite.play("heart_spin")
	heart_animation_player.play("heart_spring")
	area_2d.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if controller:
		controller.collect_heart(self)
