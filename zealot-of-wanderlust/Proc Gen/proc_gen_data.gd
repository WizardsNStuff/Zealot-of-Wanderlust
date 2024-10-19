extends Node
class_name ProcGenData

# number of iterations to run the randomwalk aglo
@export var room_iterations : int = 10

@export var room_walk_length : int = 10
# start at a random position on subsequent iterations rather than startPosition
# when true it creates larger rooms
@export var room_start_randomly_each_iteration : bool = true

@export var corridor_walk_length : int = 10

@export var room_amount_percent : float = 0.5

var start_position : Vector2i = Vector2i.ZERO
var direction_list : Array = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]
