extends Node2D
class_name Model

# Player variable
@export var player : Player

@export var skeleton_enemy : PackedScene
@export var minotaur_enemy : PackedScene
@export var slime_enemy : PackedScene

@export var enemy_spawner : Node

var spawn_duration : float = 10.0
var spawn_interval : float = 1.0
var spawn_timer : Timer
var stop_timer : Timer

var spawning_enabled = true

@export var heart : PackedScene

@export var consumables_node : Node

@export var timers : Node

# Enemies
#@export var enemies := Array([], TYPE_OBJECT, "CharacterBody2D", Enemy)

@export var proc_gen_data : ProcGenData

@export var tutorial_data : TutorialData

var in_tutorial = false

# Skills
var skills := Array([], TYPE_OBJECT, "Node", Skill)
var skill_weights := PackedFloat32Array()

func _ready() -> void:
	skills.append(AttackUp.new())
	skills.append(FireRateUp.new())
	skills.append(ProjectileRangeUp.new())
	skills.append(ProjectileSpeedUp.new())
	skills.append(ProjectileSizeUp.new())
	skills.append(AttackUpFireRateDown.new())
	skills.append(FireRateUpAttackDown.new())
	skills.append(MoveSpeedUp.new())
	# array representing the Weights of each skill
	for skill in skills:
		(skill as Skill)._ready()
		(skill as Skill).player = player
		if ((skill as Skill).tier == Skill.Rarity.COMMON):
			skill_weights.append(1.0)
		else:
			skill_weights.append(0.5/(skill as Skill).tier)
