extends Node
class_name ProcGenAlogrithm

# number of iterations to run the randomwalk aglo
@export var iterations : int = 10
# number 
@export var walk_length : int = 10
# start at a random position on subsequent iterations rather than startPosition
# when true it creates larger rooms
@export var start_randomly_each_iteration : bool = true

var start_position : Vector2i = Vector2i.ZERO
var direction_list : Array = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]
