extends Area2D
class_name Sword

# Contact damage is seperate from the projectile that will be shot
@export var contact_damage : float = 25

@export var hitbox : CollisionShape2D 


func _on_body_entered(body: Node2D) -> void:
	if body is Enemy:
		body.take_damage(contact_damage)
