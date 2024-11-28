extends CanvasLayer
class_name View

@export var controller : Controller

@export var main_menu_node : MainMenu
@export var game_over_node : GameOver
@export var level_up_node: LevelUp
@export var score_label : Label
@export var player_level_label : Label
@export var animated_key_sprite : AnimatedSprite2D
@export var key_animation_player : AnimationPlayer
@export var health_bar : HealthBar
@export var floor_label : Label

func start_level() -> void:
	#controller.reset_player()
	controller.play_again()
	controller.start_level()
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	main_menu_node.hide()
	health_bar.show()

func start_tutorial() -> void:
	controller.start_tutorial()
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	main_menu_node.hide()
	health_bar.show()

func stop_tutorial() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	main_menu_node.show()
	health_bar.hide()
	health_bar.hide()
	floor_label.hide()
	player_level_label.hide()
	score_label.hide()
	stop_key_animation()
	

func play_again() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
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
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	game_over_node.score_label.text = "Score: " + str(controller.player.score)
	main_menu_node.hide()
	health_bar.hide()
	floor_label.hide()
	player_level_label.hide()
	score_label.hide()
	game_over_node.show()

func quit_game() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	controller.quit_game()


### ||| LEVEL UP RELATED FUNCTIONS ||| ###
### vvv                            vvv ###

func level_up() -> void:
	level_up_node.show()

func init_skills(skill1 : Skill, skill2 : Skill, skill3 : Skill) -> void:
	level_up_node.setSkill1Properties(skill1)
	level_up_node.setSkill2Properties(skill2)
	level_up_node.setSkill3Properties(skill3)

func skill1_chosen() -> void:
	controller.add_skill(level_up_node.skill1)
	level_up_node.hide()

func skill2_chosen() -> void:
	controller.add_skill(level_up_node.skill2)
	level_up_node.hide()

func skill3_chosen() -> void:
	controller.add_skill(level_up_node.skill3)
	level_up_node.hide()
