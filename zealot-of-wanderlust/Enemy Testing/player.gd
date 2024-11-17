extends CharacterBody2D


const SPEED = 150
const JUMP_VELOCITY = -400.0


func _physics_process(delta: float) -> void:
	# Get the input direction for both horizontal and vertical movement.
	var direction_x := Input.get_axis("ui_left", "ui_right")
	var direction_y := Input.get_axis("ui_up", "ui_down")
	
	# Update the velocity based on input for both axes.
	if direction_x:
		velocity.x = direction_x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if direction_y:
		velocity.y = direction_y * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)

	# Move the character with the updated velocity.
	move_and_slide()
