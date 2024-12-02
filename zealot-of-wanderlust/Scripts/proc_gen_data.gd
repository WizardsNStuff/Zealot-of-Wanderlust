extends Node
class_name ProcGenData

# the tilemap layer for the floor
@export var floor_tilemap_layer : FloorTileMapLayer

# the tilemap layer for the walls
@export var wall_tilemap_layer : WallTileMapLayer

# the tilemap layer for the staircases
@export var staircase_tilemap_layer : StaircaseTileMapLayer

# the tilemap layer for the doors
@export var door_tilemap_layer : DoorTileMapLayer

# the tilemap layer for the objects
@export var object_tilemap_layer : ObjectTileMapLayer

# the tilemap layer for the background
@export var background_tilemap_layer : BackgroundTileMapLayer

@export var doors_root_node : Node

# number of iterations to run the random walk aglorithm
@export var room_iterations : int = 500

# length of each random walk step when generating rooms
@export var room_walk_length : int = 18

# whether to start the random walk at a new random position for each iteration
# when true, this creates larger rooms
@export var room_start_randomly_each_iteration : bool = false

# minimum allowed width for rooms
@export var min_room_width : int = 20

# minimum allowed height for rooms
@export var min_room_height : int = 20

# total width of the dungeon
@export var dungeon_width : int = 80

# total height of the dungeon
@export var dungeon_height : int = 80

# number of extra tiles added around the dungeon for the background tile generation
@export var background_padding : int = 10

# 
@export var bsp_random_splits : bool = false

# list of directions for random walk
var direction_list : Array = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]

var dungeon_created : bool = false

var generated_rooms : Array = []

var current_room

var exit_location : Vector2i = Vector2i()

var has_key : bool = false

enum ROOM_TYPE {SKELETONS, SKELETONS_AND_MINOTAURS, SKELETONS_AND_SLIMES, MINOTAURS}

var current_dungeon_floor : int = 1

# for testing purposes remove walls from the dungeons
@export var paint_walls = true

# for testing purposes
@export var permanent_key = false
