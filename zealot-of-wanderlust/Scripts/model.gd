extends Node2D
class_name Model

# Player variable
@export var player : Player

@export var basic_enemy : PackedScene

@export var enemy_spawner : Node

var spawn_duration : float = 10.0
var spawn_interval : float = 1.0
var spawn_timer : Timer
var stop_timer : Timer

@export var timers : Node

# Enemies
@export var enemies := Array([], TYPE_OBJECT, "CharacterBody2D", Enemy)

@export var proc_gen_data : ProcGenData
