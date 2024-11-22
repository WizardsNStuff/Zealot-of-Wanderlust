extends CanvasLayer
class_name View

@export var controller : Controller

@export var main_menu_node : MainMenu
@export var game_over_node : GameOver
@export var health_label : Label
@export var score_label : Label
@export var animated_key_sprite : AnimatedSprite2D
@export var key_animation_player : AnimationPlayer

func start_level() -> void:
	controller.start_level()
	$MainMenu.hide()
	$HealthBar.show()
func play_again() -> void:
	controller.play_again()
	controller.start_level()
	$GameOver.hide()

func play_key_animation() -> void:
	animated_key_sprite.visible = true
	animated_key_sprite.play("key_spin")
	key_animation_player.play("key_display")

func stop_key_animation() -> void:
	animated_key_sprite.visible = false
	animated_key_sprite.stop()
	key_animation_player.stop()

func game_over() -> void:
	game_over_node.score_label.text = "Score: " + str(controller.player.score)
	$MainMenu.hide()
	$PlayerHealth.hide()
	$HealthBar.hide()
	$PlayerScore.hide()
	$GameOver.show()

func quit_game() -> void:
	controller.quit_game()
