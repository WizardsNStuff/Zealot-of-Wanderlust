extends Skill
class_name AttackUp


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	skill_name = "Projectile Damage Up"
	description = "Increases Damage of Projectiles"

func add_effect(projectile : Projectile) -> void:
	projectile.damage += 2.5