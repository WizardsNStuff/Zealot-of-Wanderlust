extends CharacterBody2D
class_name Player

var speed = 150

var health : float = 200
var original_health : float
signal damage_taken(damage: float)

var score : float = 0

var iframes := 1.0

# Projectile Stats
var damage : float = 25
var projectile_speed : float = 225
var projectile_life_span : float = 0.35
var damage_cooldown: float = 1.0

var skill_list := Array([], TYPE_OBJECT, "Node", Skill)

var level : int = 1
var level_up_threshold : int = 100
signal level_up
var experience : int = 0 :
	set(value):
		if value >= level_up_threshold:
			print("level up")
			level_up.emit()
			level += 1
			experience = abs(level_up_threshold - value)
			level_up_threshold *= 1.1
		else:
			experience = value

@export var animations : AnimationPlayer
@onready var sprite : Sprite2D = $Sprite2D
@onready var damage_flash_timer : Timer = $DamageFlashTimer

@export var weapon : Weapon

var last_animation_direction : String = "down"

var is_attacking : bool = false

func _ready() -> void:
	original_health = health
	speed = 150
	health = 200
	original_health
	score = 0
	iframes = 1.0
	# Projectile Stats
	damage = 25
	projectile_speed = 225
	projectile_life_span = 0.35
	damage_cooldown = 1.0
	skill_list = Array([], TYPE_OBJECT, "Node", Skill)
	level = 1
	level_up_threshold = 100
	experience = 0
	

##### Player Stats #####
# Leviathan
var charged_damage : int
var charged_damage_cooldown : float
# Counter
var parry_cooldown : float
########################


func _on_timer_timeout() -> void:
	sprite.modulate = Color.WHITE
