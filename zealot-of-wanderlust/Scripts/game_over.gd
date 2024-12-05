extends Control
class_name GameOver

@export var view : View
@export var play_again_btn : Button
@export var exit_btn : Button
@export var score_label : Label

func _ready() -> void:
	play_again_btn.pressed.connect(view.play_again)
	exit_btn.pressed.connect(view.exit_to_main_menu)
