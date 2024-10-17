extends CanvasLayer
class_name ProcGenView

@export var proc_gen_controller : ProcGenController
@export var gen_dungeon_btn : Button

func _ready() -> void:
	gen_dungeon_btn.pressed.connect(proc_gen_controller.run_proc_gen)


func _process(_delta: float) -> void:
	pass
