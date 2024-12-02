extends Enemy
class_name Slime


@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D
@onready var littleSlime1 = preload("res://Enemy Testing/slime.tscn")
@onready var littleSlime2 = preload("res://Enemy Testing/slime.tscn")
var splitting = false

func _ready() -> void:
	# redefining variables inherited from Enemy
	speed = 30
	attack_range = 20
	score = 10
	
	# redefining variables inherited from GameCharacter
	health = 50
	defense = 10
	main_damage = 10
	main_damage_cooldown = 2
	
	# delete this line when this enemy is ready to be pushed
	$HealthBar.init_health(health)
	
	$HealthBarTimer.connect("timeout", Callable(self, "health_bar_timer_timeout"))
	#$DmgTestingTimer.connect("timeout", Callable(self, "testing_timer_timeout"))
	$DamageFlashTimer.connect("timeout", Callable(self, "_on_timer_timeout"))

func _physics_process(delta: float) -> void:
	makepath()
	var direction = global_position.direction_to(nav_agent.get_next_path_position())
	velocity = direction * speed
	move_and_slide()


# sets the target pos of the path to the players global pos
func makepath() -> void:
	nav_agent.target_position = player.global_position

# TODO: Make a function that makes sure slimes don't spawn in/beyond walls (Adam will implement this (hopefully))
func split_into_two(little_slime: CharacterBody2D, spawn_side: int) -> void:
	little_slime.player = player
	little_slime.controller = controller
	little_slime.get_node("MainSprite").scale = Vector2(0.65, 0.65)
	little_slime.get_node("CollisionShape2D").scale = Vector2(0.65, 0.65)
	#little_slime.get_node("Healthbar").scale = Vector2(0.65, 0.65)
	
	match spawn_side:
		0:
			little_slime.position = self.global_position - Vector2(15, 0)
		1:
			little_slime.position = self.global_position - Vector2(-15, 0)
	get_parent().add_child(little_slime)


func slime_spawn_pos_solver(slime: CharacterBody2D) -> void:
	pass


# this may mostly be the same as the take_damage from the enemy script, but I needed to put
# it here again for the slime splitting (well I could do it differently but I will do it this way for now)
func take_damage(damage_amount : float) -> void:
	health -= damage_amount
	DamageNumbers.display_number(damage_amount, damage_number_origin.global_position, false)
	print(damage_amount)
	if health <= 0:
		controller.update_score(score)
		if controller.check_key_status():
			controller.give_player_key()
	
		# only split into two if the current slime instance is the original slime
		if self.name == "Slime":
			split_into_two(littleSlime1.instantiate(), 0)
			split_into_two(littleSlime2.instantiate(), 1)
		self.queue_free()
	
	# show/hide certain nodes when damage is taken
	$HealthBar.show()
	$HealthBarTimer.start()
	$HealthBar._set_health(health)
	sprite.modulate = Color.RED
	damage_timer.start()

#func testing_timer_timeout():
	#print("damage taken")
	#self.take_damage(25)
