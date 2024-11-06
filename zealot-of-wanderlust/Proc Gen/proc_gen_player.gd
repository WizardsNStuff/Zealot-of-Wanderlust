extends CharacterBody2D
class_name ProcGenPlayer

@export var speed = 200

@export var animations : AnimationPlayer

@export var weapon : Node2D

var last_animation_direction : String = "down"

var is_attacking : bool = false
