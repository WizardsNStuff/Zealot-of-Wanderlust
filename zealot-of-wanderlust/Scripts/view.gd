extends CanvasLayer
class_name View

@export var controller : Controller

@export var main_menu_node : MainMenu
@export var game_over_node : GameOver
@export var level_up_node: LevelUp
@export var health_label : Label
@export var score_label : Label
@export var exp_label : Label
@export var player_level_label : Label
@export var animated_key_sprite : AnimatedSprite2D
@export var key_animation_player : AnimationPlayer
@export var health_bar : HealthBar
@export var floor_label : Label

func start_level() -> void:
	controller.start_level()
	main_menu_node.hide()
	health_bar.show()

func play_again() -> void:
	controller.play_again()
	controller.start_level()
	game_over_node.hide()

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
	main_menu_node.hide()
	health_label.hide()
	health_bar.hide()
	exp_label.hide()
	floor_label.hide()
	player_level_label.hide()
	score_label.hide()
	game_over_node.show()

func quit_game() -> void:
	controller.quit_game()


### ||| LEVEL UP RELATED FUNCTIONS ||| ###
### vvv                            vvv ###

func level_up() -> void:
	level_up_node.show()

func init_skill1(name: String, description: String, icon: Resource) -> void:
	level_up_node.setSkill1Properties(name, description, icon)

func init_skill2(name: String, description: String, icon: Resource) -> void:
	level_up_node.setSkill2Properties(name, description, icon)

func init_skill3(name: String, description: String, icon: Resource) -> void:
	level_up_node.setSkill3Properties(name, description, icon)

func skill1_chosen() -> void:
	#controller.skill1_chosen()
	level_up_node.hide()

func skill2_chosen() -> void:
	pass
	#controller.skill2_chosen()
	level_up_node.hide()

func skill3_chosen() -> void:
	pass
	#controller.skill3_chosen()
	level_up_node.hide()
