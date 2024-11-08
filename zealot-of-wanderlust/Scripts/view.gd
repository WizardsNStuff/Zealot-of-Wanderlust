extends CanvasLayer
class_name View

@export var controller : Controller
@export var health_label : Label
@export var score_label : Label
@export var game_over_node : GameOver

func start_level() -> void:
	controller.start_level()
	$MainMenu.hide()

func play_again() -> void:
	controller.play_again()
	controller.start_level()
	$GameOver.hide()

func game_over() -> void:
	game_over_node.score_label.text = "Score: " + str(controller.player.score)
	$MainMenu.hide()
	$Health.hide()
	$Score.hide()
	$GameOver.show()
	
	

func quit_game() -> void:
	controller.quit_game()
