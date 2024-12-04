extends Enemy
class_name Archer


func _ready() -> void:
	# redefining variables inherited from Enemy
	speed = 30
	attack_range = 20
	score = 10
	
	# redefining variables inherited from GameCharacter
	health = 100
	defense = 10
	main_damage = 10
	main_damage_cooldown = 2
	
	# delete this line when this enemy is ready to be pushed
	$HealthBar.init_health(health)
	
	$HealthBarTimer.connect("timeout", Callable(self, "health_bar_timer_timeout"))
	#$DmgTestingTimer.connect("timeout", Callable(self, "testing_timer_timeout"))
	$DamageFlashTimer.connect("timeout", Callable(self, "_on_timer_timeout"))
