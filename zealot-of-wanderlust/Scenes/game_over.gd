extends Control
class_name GameOver

@export var view : View
@export var play_again_btn : Button
@export var quit_btn : Button
@export var score_label : Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play_again_btn.pressed.connect(view.play_again)
	quit_btn.pressed.connect(view.quit_game)
