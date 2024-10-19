extends CanvasLayer
class_name ProcGenView

@export var proc_gen_controller : ProcGenController
@export var gen_room_btn : Button
@export var gen_corridor_btn : Button

func _ready() -> void:
	gen_room_btn.pressed.connect(proc_gen_controller.run_proc_gen)
	gen_corridor_btn.pressed.connect(proc_gen_controller.corridor_first_generation)


func _process(_delta: float) -> void:
	pass
