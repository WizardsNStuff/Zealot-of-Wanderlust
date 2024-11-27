extends Skill
class_name ProjectileRangeUp

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	skill_name = "Projectile Range Up"
	description = "Projectiles Will Last Longer Before Disappearing"
	image_reference = load("res://Skills/ProjectileRangeUp.png")


func add_effect(projectile : Projectile) -> void:
	projectile.projectile_life += 1.0
