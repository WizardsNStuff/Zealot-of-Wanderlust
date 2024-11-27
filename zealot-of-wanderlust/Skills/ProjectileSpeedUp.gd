extends Skill
class_name ProjectileSpeedUp

var skill_used := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	skill_name = "Projectile Speed Up"
	description = "Projectiles Will Move Faster Before Disappearing"
	image_reference = load("res://Skills/ProjectileSpeedUp.png")


func add_effect(projectile : Projectile) -> void:
	# Won't increase fire rate below 0 seconds
	# Will only be used once
	if (!skill_used && player.damage_cooldown >= 0.1):
		skill_used = true
		player.projectile_speed += 25
