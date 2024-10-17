extends Node
class_name Controller

@export var model : Model

func _physics_process(_delta: float) -> void:
	# For each enemy: move them accordingly
	for enemy in model.enemies:
		# update enemy.velocity before move_and_slide()
		enemy.move_and_slide()
	
	# Player Movement
	model.player.velocity = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	model.player.move_and_slide()
