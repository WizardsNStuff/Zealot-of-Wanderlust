extends Skill
class_name AttackUpFireRateDown

var skill_used := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	skill_name = "Corrupted Attack Up"
	description = "Largely Increases Damage of Projectiles, But Lowers Fire Rate"
	image_reference = load("res://Skills/AttackUpFireRateDown.png")
	tier = Skill.Rarity.UNCOMMON

func add_effect(projectile : Projectile) -> void:
	projectile.damage += 7.5
	if (!skill_used && player.damage_cooldown >= 0.1):
		skill_used = true
		player.damage_cooldown += 0.1
