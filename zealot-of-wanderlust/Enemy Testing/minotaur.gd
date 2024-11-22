extends Enemy
class_name Minotaur

### NOTE ###
	# I will prob update this code to use my state machine scene later on,
	# but for now this is the code

@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D

# Minotaur mechanic variables/states
var locked_on_player_timer = 0.0
var can_charge_again_timer = 3.5
var rushing = false
var last_known_dir = Vector2(0, 0)

func _ready() -> void:
	# was tryna make it so that the enemy doesn't slide down the wall when
	# charging but it didn't rlly do much but it's fine for now
	self.max_slides = 1
	
	# redefining variables inherited from Enemy
	speed = 50
	attack_range = 20
	score = 100
	
	# redefining variables inherited from GameCharacter
	health = 200
	defense = 20
	main_damage = 35
	main_damage_cooldown = 5
	$DamagedSpriteTimer.connect("timeout", Callable(self, "damaged_sprite_timer_timeout"))
	$HealthBarTimer.connect("timeout", Callable(self, "health_bar_timer_timeout"))
	#$Timer.connect("timeout", Callable(self, "test"))



func _physics_process(delta: float) -> void:
	
	# normal state: enemy is pathfinding and moving normally in this code block
	if not rushing:
		var direction = to_local(nav_agent.get_next_path_position()).normalized()
		last_known_dir = direction
		$RayCast2D.rotation = direction.angle()
		$RayCast2D.force_raycast_update()
		velocity = direction * speed
		makepath()
		move_and_slide()
		
		# decrease charge cooldown timer
		if can_charge_again_timer > 0:
			can_charge_again_timer -= delta
		
		# add time when raycast collides with player so enemy can soon change states
		# you could check if the raycast collider is player but it should be fine with just collision
		# mask layers (both raycast and player are on collision layer 3 so it works fine) 
		if ($RayCast2D.is_colliding() and can_charge_again_timer <= 0):
			locked_on_player_timer += delta
		
		if locked_on_player_timer >= 0.2:
			rushing = true
			locked_on_player_timer = 0.0
	
	
	# enter rushing state: move to the last known direction at a fast speed
	else:
		velocity = last_known_dir * 300
		move_and_slide()
	
		var collision
	
		for i in range(get_slide_collision_count()):
			collision = get_slide_collision(i)
			if collision || locked_on_player_timer >= 2.0:
				velocity = Vector2i.ZERO
				break

		locked_on_player_timer += delta
		# this is how we go back to the 'ready/normal' state
		if (locked_on_player_timer >= 2.0) || collision:
			rushing = false
			locked_on_player_timer = 0.0
			can_charge_again_timer = 3.5


# sets the target pos of the path to the players global pos
func makepath() -> void:
	nav_agent.target_position = player.global_position

# connect this to 'Timer' if you want to actually see the pathfinding path
# cause in physics process it goes too fast to be visible
func test():
	makepath()
