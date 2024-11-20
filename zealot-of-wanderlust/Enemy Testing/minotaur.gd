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
	speed = 65
	attack_range = 20
	score = 100
	
	# redefining variables inherited from GameCharacter
	health = 200
	defense = 20
	main_damage = 35
	main_damage_cooldown = 5



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
		if ($RayCast2D.is_colliding() and can_charge_again_timer <= 0):
			locked_on_player_timer += delta
		
		if locked_on_player_timer >= 0.2:
			rushing = true
			locked_on_player_timer = 0.0
	
	
	# enter rushing state: move to the last known direction at a fast speed
	else:
		velocity = last_known_dir * 300
		move_and_slide()
		locked_on_player_timer += delta
		# this is how we go back to the 'ready/normal' state
		if (locked_on_player_timer >= 2.0):
			rushing = false
			locked_on_player_timer = 0.0
			can_charge_again_timer = 3.5


# sets the target pos of the path to the players global pos
func makepath() -> void:
	nav_agent.target_position = player.global_position
