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
	main_damage_cooldown = 1.5
	$Timer.connect("timeout", Callable(self, "damaged_sprite_timer_timeout"))

func take_damage(damage_amount : float) -> void:
	health -= damage_amount
	$MainSprite.hide()
	$DamagedSprite.show()
	$Timer.start()
	if health <= 0:
		$MainSprite.hide()
		$DamagedSprite.show()
		$Timer.start()
		controller.update_score(score)
		if controller.check_key_status():
			controller.give_player_key()
		self.queue_free()

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

func damaged_sprite_timer_timeout():
	$MainSprite.show()
	$DamagedSprite.hide()
