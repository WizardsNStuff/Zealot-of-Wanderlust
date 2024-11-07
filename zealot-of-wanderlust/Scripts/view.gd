extends CanvasLayer
class_name View

@export var controller : Controller

func _ready() -> void:
	pass

func start_level() -> void:
	controller.start_level()
	$MainMenu.hide()

func _process(delta: float) -> void:
	pass
