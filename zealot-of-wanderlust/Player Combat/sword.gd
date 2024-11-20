extends Area2D
class_name Sword

@export var damage : float = 100

@export var hitbox : CollisionShape2D 


func _on_body_entered(body: Node2D) -> void:
	if body is Enemy:
		body.take_damage(damage)
