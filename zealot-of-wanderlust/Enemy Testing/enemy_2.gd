extends CharacterBody2D
class_name Enemy2

const speed = 90

@export var player: Node2D
@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D
@onready var state_machine = $StateMachine

# Minotaur mechanic variables/states
var charge_up_timer = 0.0
var rushing = false
var last_known_dir = Vector2(0, 0)


### Minotaur gameplan ###
# If the raycast2D (The minotaurs line of sight) has collided (seen) the player
# for like 1 whole second, then make the minotaur charge in a straight line
# at the direction that was last known/recorded when that timer ran out
func _physics_process(delta: float) -> void:
	if (rushing == false):
		$Label.text = "Normal State"
		var direction = to_local(nav_agent.get_next_path_position()).normalized()
		last_known_dir = direction
		$RayCast2D.rotation = direction.angle()
		$RayCast2D.force_raycast_update()
		velocity = direction * speed
		makepath()
		move_and_slide()
		
		if ($RayCast2D.is_colliding()):
			charge_up_timer += delta
	
	if (charge_up_timer >= 0.5):
		$Label.text = "RUSH STATE!"
		rushing = true
		if (charge_up_timer >= 2.0):
			rushing = false
			charge_up_timer = 0.0
		velocity = last_known_dir * 300
		move_and_slide()
		charge_up_timer += delta


func makepath() -> void:
	nav_agent.target_position = player.global_position


func _on_timer_timeout() -> void:
	pass
	#makepath()
