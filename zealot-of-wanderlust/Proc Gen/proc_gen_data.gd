extends Node
class_name ProcGenData

# number of iterations to run the random walk aglorithm
@export var room_iterations : int = 10

# length of each random walk step when generating rooms
@export var room_walk_length : int = 10

# whether to start the random walk at a new random position for each iteration
# when true, this creates larger rooms
@export var room_start_randomly_each_iteration : bool = true

# length of each random walk step when generating corridors
@export var corridor_walk_length : int = 10

# number of corridors to generate
@export var corridor_amount : int = 5

# the chance that a room will spawn at the end of a newly generated corridor
@export_range(0.1, 1.0) var room_amount_percent : float = 0.5

# minimum allowed width for rooms
@export var min_room_width : int = 4

# minimum allowed height for rooms
@export var min_room_height : int = 4

# total width of the dungeon
@export var dungeon_width : int = 20

# total height of the dungeon
@export var dungeon_height : int = 20

# offset subtracted from the width and height of the room's edges when generating rooms; 
# makes the room smaller by 2 * offset
# *** min(min_room_width, min_room_height) / (room_offset * 2) > 1 MUST BE TRUE ***
# this ensures that the room does not shrink below the min allowed size or result is a room of size 0
@export_range(0, 10) var room_offset : int = 1

# whether to use random walk when generating rooms
@export var random_walk_room : bool = false

#var dungeon_floor : int = 1
#enum room_type { ENTRANCE, GOBLIN_LAIR, ORC_CAVE, TROLL_TUNNEL, DRAGON_DEN, EXIT}

@export var bsp_random_splits : bool = false

# starting position for dungeon generation
var start_position : Vector2i = Vector2i.ZERO

# list of directions for random walk
var direction_list : Array = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]
