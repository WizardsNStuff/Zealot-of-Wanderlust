extends GameCharacter
class_name Enemy

var speed = 75
var attack_range = 28
# this variable is kinda useless but without it the main_damage_cooldown felt useless so
var cooldown = 0
# the file path for this will obv change once we get everything hooked up to MVC
@export var player : ProcGenPlayer

func _ready() -> void:
	
	### Declaring attributes from GameCharacterScript ###
	health = 100
	defense = 20
	main_damage = 15
	main_damage_cooldown = 3.5

func take_damage(damage_amount : float) -> void:
	health -= damage_amount
	if health <= 0:
		queue_free()


func _physics_process(delta: float) -> void:
	# move towards player with normalized direction
	position += (player.position - position).normalized() * speed * delta
	
	var distance_to_player = position.distance_to(player.position)
	
	# if enemy is close enough to the player then deal damage
	if distance_to_player <= attack_range:
		if cooldown <= 0:
			print("enemy is doing damage")
			# deal damage to player code would go here
			cooldown = main_damage_cooldown

	
	# decrease the cooldown timer each frame
	if cooldown > 0:
		cooldown -= delta
