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
var rush_damage : float
var rush_speed : float
var last_known_dir = Vector2(0, 0)

func _ready() -> void:
	# was tryna make it so that the enemy doesn't slide down the wall when
	# charging but it didn't rlly do much but it's fine for now
	self.max_slides = 1
	
	# redefining variables inherited from Enemy
	speed = 50
	rush_speed = 350
	attack_range = 20
	score = 50
	
	# redefining variables inherited from GameCharacter
	health = 200
	defense = 20
	main_damage = 50
	main_damage_cooldown = 0
	rush_damage = main_damage * 1.5
	$HealthBarTimer.connect("timeout", Callable(self, "health_bar_timer_timeout"))
	#$Timer.connect("timeout", Callable(self, "test"))



func _physics_process(delta: float) -> void:
	
	# normal state: enemy is pathfinding and moving normally in this code block
	if not rushing:
		
		# decrease charge cooldown timer
		if can_charge_again_timer > 0:
			can_charge_again_timer -= delta
		
		# add time when raycast collides with player so enemy can soon change states
		# you could check if the raycast collider is player but it should be fine with just collision
		# mask layers (both raycast and player are on collision layer 3 so it works fine) 
		if ($RayCast2D.is_colliding() and can_charge_again_timer <= 0):
			velocity = Vector2(0, 0)
			move_and_slide()
			locked_on_player_timer += delta
		else:
			makepath()
			if !NavigationServer2D.map_get_iteration_id(nav_agent.get_navigation_map()):
				return
			var direction = global_position.direction_to(nav_agent.get_next_path_position())
			last_known_dir = to_local(player.global_position).normalized()
			$RayCast2D.rotation = last_known_dir.angle()
			$RayCast2D.force_raycast_update()
			velocity = direction * speed
			move_and_slide()
		
		if locked_on_player_timer >= 1.0:
			rushing = true
			locked_on_player_timer = 0.0
	
	
	# enter rushing state: move to the last known direction at a fast speed
	else:
		velocity = last_known_dir * rush_speed
		move_and_slide()
	
		var collision
	
		for i in range(get_slide_collision_count()):
			collision = get_slide_collision(i)
			if collision && collision.get_collider() is Player:
				velocity = speed * last_known_dir
				(collision.get_collider() as Player).damage_taken.emit(rush_damage)
				break
			elif collision || locked_on_player_timer >= 2.0:
				velocity = speed * last_known_dir
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
