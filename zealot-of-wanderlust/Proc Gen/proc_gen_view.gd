extends CanvasLayer
class_name ProcGenView

@export var proc_gen_controller : ProcGenController

@export var start_btn : Button
@export var key_btn : Button

func _ready() -> void:
	start_btn.pressed.connect(proc_gen_controller.start_level)
	key_btn.pressed.connect(proc_gen_controller.give_player_key)
