extends Control

@export var view : View
@export var play_again_btn : Button
@export var quit_btn : Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play_again_btn.pressed.connect(view.play_again)
	quit_btn.pressed.connect(view.quit_game)
