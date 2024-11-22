extends CharacterBody2D
class_name Player

var speed = 200

var health : float = 200
var original_health : float

var score : float = 0

var damage : float = 25
var projectile_speed : float = 225
var projectile_life_span : float = 0.5
var damage_cooldown: float = 0.75

var level : int = 1
var level_up_threshold : int = 29
signal level_up
var experience : int = 0 :
	set(value):
		if value >= level_up_threshold:
			level_up.emit()
			level += 1
			experience = abs(level_up_threshold - value)
			level_up_threshold *= 1.1
		else:
			experience = value

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
