extends Skill
class_name MoveSpeedUp

var skill_used := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	skill_name = "Move Speed Up"
	description = "Walk Faster"
	image_reference = load("res://Skills/MoveSpeedUp.png")

func add_effect(projectile : Projectile) -> void:
	# Will only be used once
	if (!skill_used):
		skill_used = true
		player.speed += 10
