extends Skill
class_name FireRateUp

var skill_used := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	skill_name = "Fire Rate Up"
	description = "Increases Speed of Attacks"

func add_effect(projectile : Projectile) -> void:
	# Won't increase fire rate below 0 seconds
	# Will only be used once
	if (!skill_used && player.damage_cooldown >= 0.1):
		skill_used = true
		player.damage_cooldown -= 0.05
