extends Node
class_name TutorialData

var controller 

@export var floor : TileMapLayer
var floor_tile_atlas = 6
var enemy_1_tile_position = Vector2i(39, -2)
var enemy_2_tile_position = Vector2i(39, 1)
var enemy_3_tile_position = Vector2i(51, 0)
var enemy_4_tile_position = Vector2i(66, -1)
var heart_tile_position = Vector2i(81, -1)

@export var d1 : Node2D
@export var d2 : Node2D
@export var d3 : Node2D
@export var d4 : Node2D
@export var d5 : Node2D
@export var d6 : Node2D
@export var d7 : Node2D

func checkpoint_entered(checkpoint) -> void:
	match checkpoint:
		"c1":
			d1.messages = ["use the W, A, S, D keys to move the player"]
			d1.start_dialogue()
		"c2":
			d2.messages = ["use the arrow keys to fire a projectile at the enemy"]
			d2.start_dialogue()
		"c3":
			d3.messages = ["killing enemies earns score and exp", 
			"earn exp to level up your player",
			"leveling up allows you to choose 1 new skill"
			]
			d3.start_dialogue()
		"c4":
			d4.messages = ["kill all enemies within a room to earn a key", 
			"keys can be used to unlock doors and progress to the next room"
			]
			d4.start_dialogue()
		"c5":
			d5.messages = ["getting hit by an enemy lowers your health"]
			d5.start_dialogue()
			controller.tutorial_damage_section()
		"c6":
			d6.messages = ["1 heart can be fond on each floor", "hearts give you +10 health"]
			d6.start_dialogue()
			controller.tutorial_pause(6)
		"c7":
			d7.messages = ["the last room in each floor contains a staircase", 
			"the staircase can be acessed by using a key", 
			"the staircase takes you up to the next floor where enemies get stronger"
			]
			d7.start_dialogue()
			controller.tutorial_pause(12)
		"c8":
			controller.give_player_key()


func _on_stairs_body_entered(body: Node2D) -> void:
	controller.stop_tutorial()
