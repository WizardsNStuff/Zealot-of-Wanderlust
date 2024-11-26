extends Skill
class_name ProjectileRangeUp

var skill_used := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	skill_name = "Projectile Range Up"
	description = "Projectiles Will Last Longer Before Disappearing"


func add_effect(projectile : Projectile) -> void:
	# Will only be used once
	if (!skill_used):
		skill_used = true
		player.projectile_life_span += 0.075
