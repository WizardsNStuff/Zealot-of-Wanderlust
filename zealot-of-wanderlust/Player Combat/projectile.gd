extends CharacterBody2D
class_name Projectile

var damage : float

func _physics_process(delta: float) -> void:
	move_and_slide()
	
	var collision = get_last_slide_collision()
	if collision != null:
		var collider = collision.get_collider()
		if collider is Enemy:
			collider.take_damage(damage)
		self.queue_free()
		
		
