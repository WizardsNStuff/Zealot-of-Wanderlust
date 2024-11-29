extends GameCharacter
class_name Skeleton

var speed = 75
var attack_range = 28
var cooldown = 0
var score = 10

@export var player : Player
@export var controller : Controller
@onready var damage_numbers_origin = $DamageNumbersOrigin

func _ready() -> void:
	### Declaring attributes from GameCharacterScript ###
	health = 75
	defense = 20
	main_damage = 15
	main_damage_cooldown = 1.5
	$HealthBar.init_health(health)
	$DamagedSpriteTimer.connect("timeout", Callable(self, "damaged_sprite_timer_timeout"))
	$HealthBarTimer.connect("timeout", Callable(self, "health_bar_timer_timeout"))

func _physics_process(delta: float) -> void:
	# move towards player with normalized direction
	var direction_to_player = (player.position - self.position).normalized()
	
	self.velocity = direction_to_player * speed
	
	move_and_slide()

func take_damage(damage_amount : float) -> void:
	health -= damage_amount
	DamageNumbers.display_number(damage_amount, damage_numbers_origin.global_position, false)
	
	# show/hide certain nodes when damage is taken
	$HealthBar.show()
	$HealthBarTimer.start()
	$HealthBar._set_health(health)
	$MainSprite.hide()
	$DamagedSprite.show()
	$DamagedSpriteTimer.start()
	
	# a timer could be added here to let enemy turn red and show healthbar
	# one last time before queue_free'ing, lmk if you want that to happen

# damage timer cooldown
func startCooldown(delta: float) -> void:
	if cooldown > 0:
		cooldown -= delta

func canEnemyHit() -> bool:
	if cooldown <= 0:
		cooldown = main_damage_cooldown
		return true
	else:
		return false

func damaged_sprite_timer_timeout():
	$MainSprite.show()
	$DamagedSprite.hide()
	if health <= 0:
		controller.update_score(score)
		if controller.check_key_status():
			controller.give_player_key()
		self.queue_free()

func health_bar_timer_timeout():
	$HealthBar.hide()
