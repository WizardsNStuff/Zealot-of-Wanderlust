extends GameCharacter
class_name Enemy

var speed = 75
var attack_range = 28
var cooldown = 0
var score = 10

@export var player : Player
@export var controller : Controller

func _ready() -> void:
	### Declaring attributes from GameCharacterScript ###
	health = 100
	defense = 20
	main_damage = 15
	main_damage_cooldown = 3.5

func take_damage(damage_amount : float) -> void:
	health -= damage_amount
	if health <= 0:
		controller.update_score(score)
		queue_free()

func startCooldown(delta: float) -> void:
	if cooldown > 0:
		cooldown -= delta

func canEnemyHit() -> bool:
	if cooldown <= 0:
		cooldown = main_damage_cooldown
		return true
	else:
		return false


func _physics_process(delta: float) -> void:
	# move towards player with normalized direction
	var direction_to_player = (player.position - self.position).normalized()
	
	self.velocity = direction_to_player * speed
	
	move_and_slide()
	
	#position += (player.position - position).normalized() * speed * delta
	
	#var distance_to_player = position.distance_to(player.position)
	
	# if enemy is close enough to the player then deal damage
	#if distance_to_player <= attack_range:
		#if cooldown <= 0:
			#print("enemy is doing damage")
			## deal damage to player code would go here
			#cooldown = main_damage_cooldown
#
	#
	## decrease the cooldown timer each frame
	#if cooldown > 0:
		#cooldown -= delta
