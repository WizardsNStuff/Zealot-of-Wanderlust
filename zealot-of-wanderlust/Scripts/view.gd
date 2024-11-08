extends CanvasLayer
class_name View

@export var controller : Controller
@export var health_label : Label


func start_level() -> void:
	controller.start_level()
	$MainMenu.hide()

func play_again() -> void:
	controller.play_again()
	controller.start_level()
	$GameOver.hide()

func game_over() -> void:
	$MainMenu.hide()
	$Health.hide()
	$GameOver.show()
	

func quit_game() -> void:
	controller.quit_game()
