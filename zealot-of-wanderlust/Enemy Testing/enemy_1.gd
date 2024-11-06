extends GameCharacter

var speed = 75
var player_chase = false

# the file path for this will obv change once we get everything hooked up to MVC
@onready var player = $"../CharacterBody2D"

func _ready() -> void:
	### Declaring attributes from GameCharacterScript ###
	health = 100
	defense = 20
	main_damage = 15
	main_damage_cooldown = 1.5

func _physics_process(delta: float) -> void:
	position += (player.position - position) / speed
