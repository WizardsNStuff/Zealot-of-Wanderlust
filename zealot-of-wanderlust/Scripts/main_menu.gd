extends Control
class_name MainMenu

@export var view : View
@export var start_btn : Button
@export var quit_btn : Button
@export var tutorial_btn : Button

func _ready() -> void:
	start_btn.pressed.connect(view.start_level)
	quit_btn.pressed.connect(view.quit_game)
	tutorial_btn.pressed.connect(view.start_tutorial)
	start_btn.grab_focus()
