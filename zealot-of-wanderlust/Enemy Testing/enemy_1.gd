extends GameCharacter
class_name Enemy

var speed = 75
var attack_range = 28
var cooldown = 0
var score = 15

# if player is set to CharacterBody2D change it back to player (I change it when testing new enemies)
@export var player : Player
@export var controller : Controller
@onready var sprite : Sprite2D = $MainSprite
@export var damage_timer : Timer
@onready var damage_number_origin = $DamageNumberOrigin

func _ready() -> void:
	### Declaring attributes from GameCharacterScript ###
	health = 75
	defense = 20
	main_damage = 15
	main_damage_cooldown = 1.5
	$HealthBar.init_health(health)
	$HealthBarTimer.connect("timeout", Callable(self, "health_bar_timer_timeout"))

func _physics_process(delta: float) -> void:
	# move towards player with normalized direction
	var direction_to_player = (player.position - self.position).normalized()
	
	self.velocity = direction_to_player * speed
	
	move_and_slide()

func take_damage(damage_amount : float) -> void:
	health -= damage_amount
	DamageNumbers.display_number(damage_amount, damage_number_origin.global_position, false)
	if health <= 0:
		controller.update_score(score)
		if controller.check_key_status() && (self is not Slime):
			controller.give_player_key()
		controller.player_enemy_hit_sfx(true)
		self.queue_free()
	controller.player_enemy_hit_sfx(false)
	# show/hide certain nodes when damage is taken
	$HealthBar.show()
	$HealthBarTimer.start()
	$HealthBar._set_health(health)
	sprite.modulate = Color.RED
	damage_timer.start()

func health_bar_timer_timeout():
	$HealthBar.hide()


func _on_timer_timeout() -> void:
	sprite.modulate = Color.WHITE
