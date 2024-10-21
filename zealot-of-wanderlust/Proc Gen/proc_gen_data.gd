extends Node
class_name ProcGenData

# number of iterations to run the randomwalk aglo
@export var room_iterations : int = 10

@export var room_walk_length : int = 10
# start at a random position on subsequent iterations rather than startPosition
# when true it creates larger rooms
@export var room_start_randomly_each_iteration : bool = true

@export var corridor_walk_length : int = 10

@export var corridor_amount : int = 5

@export_range(0.1, 1.0) var room_amount_percent : float = 0.5

@export var min_room_width : int = 4

@export var min_woom_height : int = 4

@export var dungeon_width : int = 20

@export var dungeon_height : int = 20

@export_range(0, 10) var room_offset : int = 1

@export var random_walk_room : bool = false

var start_position : Vector2i = Vector2i.ZERO
var direction_list : Array = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]
