extends Skill
class_name FireRateUpAttackDown

var skill_used := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	skill_name = "Corrupted Fire Rate Up"
	description = "Largely Increases Fire Rate of Projectiles, But Lowers Damage"

func add_effect(projectile : Projectile) -> void:
	projectile.damage -= 7.5
	if (!skill_used && player.damage_cooldown >= 0.1):
		skill_used = true
		player.damage_cooldown -= 0.1
