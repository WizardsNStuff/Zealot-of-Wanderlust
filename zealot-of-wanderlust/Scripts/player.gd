extends CharacterBody2D
class_name Player

@export var speed = 200

@export var health : float = 200
var original_health : float

@export var score : float = 0

@export var damage : float = 50
var damage_cooldown: float = 0.75

@export var animations : AnimationPlayer

@export var weapon : Weapon

var last_animation_direction : String = "down"

var is_attacking : bool = false

func _ready() -> void:
	original_health = health


##### Player Stats #####
# Leviathan
var charged_damage : int
var charged_damage_cooldown : float
# Counter
var parry_cooldown : float
# Enhancement
var active_buffs := {
	# Damage applicable to any instance of damage
	"all_damage_buff": 0,
	# Blitz magic buff
	"main_damage_buff": 0,
	"main_cooldown_buff": 0,
	# Leviathan Magic buff
	"charged_damage_buff": 0,
	"charged_cooldown_buff": 0,
	# Counter Magic buff
	"parry_cooldown_buff": 0,
	# Basic Stat Buffs
	"health_buff": 0,
	"defense_buff": 0
}
########################
