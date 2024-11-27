extends Skill
class_name ProjectileSizeUp

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	skill_name = "Projectile Size Up"
	description = "Projectiles Become Larger"
	image_reference = load("res://Skills/ProjectileSizeUp.png")


func add_effect(projectile : Projectile) -> void:
	projectile.scale += Vector2(0.05, 0.05)
