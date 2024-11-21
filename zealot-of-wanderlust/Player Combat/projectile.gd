extends CharacterBody2D
class_name Projectile

var damage : float
var projectile_life : float
	
func _physics_process(delta: float) -> void:
	move_and_slide()
	if Time.get_unix_time_from_system() >= projectile_life:
		self.queue_free()
	
	var collision = get_last_slide_collision()
	if collision != null:
		var collider = collision.get_collider()
		if collider is Enemy:
			collider.take_damage(damage)
		self.queue_free()
