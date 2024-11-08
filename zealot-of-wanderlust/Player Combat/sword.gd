extends Area2D

@export var damage : float = 100


func _on_body_entered(body: Node2D) -> void:
	if body is Enemy:
		body.take_damage(damage)
	
