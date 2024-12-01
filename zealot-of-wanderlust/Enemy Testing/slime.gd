extends Enemy
class_name Slime


@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D

func _ready() -> void:
	# redefining variables inherited from Enemy
	speed = 29
	attack_range = 20
	score = 10
	
	# redefining variables inherited from GameCharacter
	health = 50
	defense = 10
	main_damage = 10
	main_damage_cooldown = 2
	$HealthBarTimer.connect("timeout", Callable(self, "health_bar_timer_timeout"))
	$DmgTestingTimer.connect("timeout", Callable(self, "testing_timer_timeout"))
	$DamageFlashTimer.connect("timeout", Callable(self, "_on_timer_timeout"))

func _physics_process(delta: float) -> void:
	makepath()
	var direction = global_position.direction_to(nav_agent.get_next_path_position())
	velocity = direction * speed
	move_and_slide()


# sets the target pos of the path to the players global pos
func makepath() -> void:
	nav_agent.target_position = player.global_position

func testing_timer_timeout():
	print("damage taken")
	self.take_damage(5)
