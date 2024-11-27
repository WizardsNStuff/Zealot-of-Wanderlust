extends Node
class_name TutorialData

var controller 

@export var floor : TileMapLayer
var floor_tile_atlas = 6
var enemy_1_tile_position = Vector2i(39, -2)
var enemy_2_tile_position = Vector2i(39, 1)
var enemy_3_tile_position = Vector2i(51, 0)
var enemy_4_tile_position = Vector2i(66, -1)
var heart_tile_position = Vector2i(77, -1)

@export var d1 : Node2D
@export var d2 : Node2D
@export var d3 : Node2D
@export var d4 : Node2D
@export var d5 : Node2D
@export var d6 : Node2D
@export var d7 : Node2D

@export var temp_wall : TileMapLayer
var temp_wall_broken = false

func checkpoint_entered(checkpoint) -> void:
	match checkpoint:
		"c1":
			d1.messages = ["use the W, A, S, D keys to move the player"]
			d1.start_dialogue()
			controller.tutorial_pause(2)
		"c2":
			d2.messages = ["use the arrow keys to fire a projectile at the enemy"]
			d2.start_dialogue()
			controller.tutorial_pause(3)
		"c3":
			d3.messages = ["killing enemies earns you score and exp", 
			"the blue exp bar is displayed directly below the health bar",
			"earn exp to level up your player",
			"leveling up allows you to learn 1 new skill"
			]
			d3.start_dialogue()
			controller.tutorial_pause(15)
		"c4":
			d4.messages = ["kill all enemies within a room to earn a key", 
			"keys can be used to unlock doors and progress to the next room"
			]
			d4.start_dialogue()
			controller.tutorial_pause(7)
		"c5":
			d5.messages = ["getting hit by an enemy lowers your health"]
			d5.start_dialogue()
			controller.tutorial_damage_section()
		"c6":
			d6.messages = ["1 heart can be found on each floor", "hearts give you additional health points"]
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

func _physics_process(delta: float) -> void:
	if !temp_wall_broken:
		if controller.model.enemy_spawner.get_child_count() <= 1:
			temp_wall_broken = true
			self.remove_child(temp_wall)
			temp_wall.queue_free()
			temp_wall = null
