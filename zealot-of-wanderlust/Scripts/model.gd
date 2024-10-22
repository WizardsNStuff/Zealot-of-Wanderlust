extends Node2D
class_name Model

# Player variable
@export var player : Player

# Enemies
@export var enemies := Array([], TYPE_OBJECT, "CharacterBody2D", Enemy)
