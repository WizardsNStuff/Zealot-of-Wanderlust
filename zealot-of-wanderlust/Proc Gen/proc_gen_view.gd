extends CanvasLayer
class_name ProcGenView

@export var proc_gen_controller : ProcGenController
@export var gen_room_btn : Button
@export var corridor_first_btn : Button
@export var room_first_btn : Button
@export var start_btn : Button
@export var key_btn : Button

func _ready() -> void:
	gen_room_btn.pressed.connect(proc_gen_controller.run_proc_gen)
	corridor_first_btn.pressed.connect(proc_gen_controller.corridor_first_generation)
	room_first_btn.pressed.connect(proc_gen_controller.room_first_gen)
	start_btn.pressed.connect(proc_gen_controller.start_level)
	key_btn.pressed.connect(proc_gen_controller.give_player_key)


func _process(_delta: float) -> void:
	pass
