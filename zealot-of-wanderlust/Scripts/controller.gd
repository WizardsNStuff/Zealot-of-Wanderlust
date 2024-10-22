extends Node
class_name Controller

@export var model : Model
var player : Player
var enemies : Array[Enemy]

func _ready() -> void:
	model = $Model
	player = model.player
	enemies = model.enemies

func _physics_process(_delta: float) -> void:
	# For each enemy: move them accordingly
	#for enemy in enemies:
		# update enemy.velocity before move_and_slide()
	#	enemy.move_and_slide()
	
	# Player Movement
	player.velocity = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	player.move_and_slide()
