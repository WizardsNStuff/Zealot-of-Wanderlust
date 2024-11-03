extends Node
class_name ProcGenController

# holds the procedural generation settings
@export var proc_gen_data : ProcGenData

# the tilemap layer for the floor
@export var floor_tilemap_layer : FloorTileMapLayer

# the tilemap layer for the walls
@export var wall_tilemap_layer : WallTileMapLayer

# the tilemap layer for the staircases
@export var staircase_tilemap_layer : StaircaseTileMapLayer

# the tilemap layer for the doors
@export var door_tilemap_layer : DoorTileMapLayer

@export var player : Player

var dungeon_created : bool = false
var generated_rooms : Array = []
var exit_location : Vector2i

# runs the procedural generation for creating the floor layout and walls
# this method generates the floor positions using a random walk algorithm
# and then paints the tiles and creates walls based on the generated positions
func run_proc_gen() -> void:
	# generate the floor positions by starting the random walk from the specified start position
	var floor_positions : Dictionary = run_random_walk(proc_gen_data.start_position)

	# get the atlas ID for the floor tilemap layer
	var floor_atlas_id : int = floor_tilemap_layer.atlas_id
	# get the position of the base floor tile in the atlas (sprite sheet)
	var floor_tile_pos : Vector2i = floor_tilemap_layer.base_floor_tile_atlas_position

	# get the atlas ID for the wall tilemap layer
	var wall_atlas_id : int = wall_tilemap_layer.atlas_id
	# get the position of the base wall tile in the atlas (sprite sheet)
	var wall_tile_pos : Vector2i = wall_tilemap_layer.base_wall_tile_atlas_position

	# clear any existing tiles in the floor and wall tilemaps before generating new ones
	clear_tiles(floor_tilemap_layer)
	clear_tiles(wall_tilemap_layer)

	# paint the floor tiles in the tilemap based on the generated floor positions
	paint_tiles(floor_positions, floor_tilemap_layer, floor_atlas_id, floor_tile_pos)

	# create walls around the painted floor tiles using the wall tilemap layer
	create_walls(floor_positions, wall_tilemap_layer, wall_atlas_id, wall_tile_pos)
	
	# uncomment the following lines to visualize the floor tile positions in the console for debugging
	#for position in floor_positions.keys():
		#print_debug(position)

# generates a room layout using a random walk algorithm starting from a given position
# the room is created by iteratively walking in random directions and placing floor tiles
func run_random_walk(position : Vector2i) -> Dictionary:
	# set the current position to the given starting position
	var current_position : Vector2i = position
	# dictionary to store the positions of the floor tiles for the room
	var floor_positions = {}

	# perform the random walk for a number of iterations defined in proc_gen_data
	for i in range(0, proc_gen_data.room_iterations - 1):
		# generate a path using the random walk for this iteration and store the result in 'path'
		var path : Dictionary = simple_random_walk_room(current_position, proc_gen_data.room_walk_length)

		# merge the newly generated floor positions (path) into the main floor_positions dictionary
		floor_positions.merge(path)

		# if configured to start from a random position after each iteration
		if (proc_gen_data.room_start_randomly_each_iteration):
			# Select a random position from the already generated floor tiles as the new starting point
			current_position = floor_positions.keys()[randi_range(0, floor_positions.size() - 1)]

	# return the dictionary containing all the positions of the floor tiles for the room
	return floor_positions

# Performs a simple random walk starting from a given position
# and generates a path of positions by moving in random directions 
# for a specified number of steps (walk_length)
func simple_random_walk_room(start_position : Vector2i, walk_length : int) -> Dictionary:
	# dictionary to store the path of the random walk
	var path : Dictionary = {}

	# add the starting position to the path dictionary
	path[start_position] = null

	# set the previous position to the starting position for the first step
	var previous_position : Vector2i = start_position

	# loop for the specified number of steps (walk_length)
	for i in range(0, walk_length):
		# calculate a new position by adding a random direction to the previous position
		var new_position : Vector2i = previous_position + get_random_direction()
		# add the new position to the path dictionary
		path[new_position] = null;
		# update the previous position to the new position for the next iteration
		previous_position = new_position

	# return the dictionary containing all positions visited during the random walk
	return path

# Returns a random direction for the procedural generation
# selects a random direction from a predefined list of directions stored in proc_gen_data
func get_random_direction() -> Vector2i:
	# pick and return a random direction from the list of directions in proc_gen_data
	return proc_gen_data.direction_list.pick_random()

# paints multiple tiles on a specified tilemap layer based on given positions
# iterate through a dictionary of tile positions and paint each tile
# using the specified tilemap layer and tile atlas information
func paint_tiles(tile_positions : Dictionary, tilemap_layer : TileMapLayer, tilemap_layer_atlas_id : int , tile_atlas_position : Vector2i) -> void:
	# iterate through each tile position in the provided dictionary
	for tile_pos in tile_positions.keys():
		# paint a single tile at the specified position using the given tilemap layer and atlas information
		paint_single_tile(tilemap_layer, tilemap_layer_atlas_id, tile_pos, tile_atlas_position)

# paints a single tile on a specified tilemap layer at a given position
# sets the cell at the specified position in the tilemap layer
# using the provided atlas ID and the specific position of the tile in the atlas (sprite sheet)
func paint_single_tile(tilemap_layer : TileMapLayer, tilemap_layer_atlas_id : int , paint_position : Vector2i, tile_atlas_position : Vector2i) -> void:
	# set the cell at the specified position in the tilemap layer with the tile texture/sprite from the atlas (sprite sheet)
	tilemap_layer.set_cell(paint_position, tilemap_layer_atlas_id, tile_atlas_position)

# clears all tiles from the specified tilemap layer
# removes any existing tiles in the tilemap layer, allowing for a fresh start before new tiles are painted
func clear_tiles(tilemap_layer : TileMapLayer) -> void:
	# call the clear method on the tilemap layer to remove all tiles
	tilemap_layer.clear()

# creates walls around the painted floor tiles by identifying wall edges
# finds the positions where walls should be placed based on the floor positions
# and then paints the wall tiles at those positions in the specified tilemap layer
func create_walls(floor_positions : Dictionary, tilemap_layer : TileMapLayer, tilemap_layer_atlas_id : int , tile_atlas_position : Vector2i) -> void:
	# find wall edge positions based on the floor positions and the defined direction list
	var wall_positions : Dictionary = find_wall_edges(floor_positions, proc_gen_data.direction_list)

	# iterate through each wall position and paint a wall tile at that position
	for position in wall_positions:
		# paint a single wall tile at the current position using the specified tilemap layer and atlas information
		paint_single_tile(tilemap_layer, tilemap_layer_atlas_id, position, tile_atlas_position)

# finds the positions where walls should be placed based on the empty neighboring tiles of the floor
# checks each floor tile position and its neighboring tiles. If a neighboring tile
# is not a floor tile, it adds that position to the list of wall positions
func find_wall_edges(floor_positions : Dictionary, direction_list : Array) -> Dictionary:
	# dictionary to store wall positions
	var wall_positions : Dictionary = {}

	# iterate through each position in the floor positions dictionary
	for position in floor_positions:
		# check each direction in the direction list
		for direction in direction_list:
			# calculate the neighbor position based on the current position and direction
			var neighbor_position = position + direction

			# if there is no floor tile at the neighbor position
			if (floor_positions.keys().has(neighbor_position) == false):
				# add the neighbor position to the wall positions
				wall_positions[neighbor_position] = null

	# return the dictionary containing all wall positions
	return wall_positions





# Corridor First Generation

# generate corridors first then add rooms, walls, and other features around them
func corridor_first_generation() -> void:
	# dictionary to store the positions of all the floor tiles (corridors and rooms)
	var floor_positions : Dictionary = {}
	# dictionary to store potential positions where rooms can be created
	var potential_room_positions : Dictionary = {}

	# clear floor and wall tilemaps before generating new corridors
	clear_tiles(floor_tilemap_layer)
	clear_tiles(wall_tilemap_layer)

	# generate corridors and store their positions in floor_positions
	# mark the end positions of these corridors as potential locations for generating rooms,
	# storing those positions in potential_room_positions for room placement later on
	var corridors : Array[Array] = create_corridors(floor_positions, potential_room_positions);

	# create rooms based on potential room positions and store their floor tile positions in room_positions
	var room_positions : Dictionary = create_rooms(potential_room_positions)

	# find all dead-end positions in the corridors and store them in the dead_ends array
	var dead_ends : Array = find_all_dead_ends(floor_positions)

	# create rooms at the identified dead-end positions, newly generated room floor positions are merged into room_positions
	create_rooms_at_dead_ends(dead_ends, room_positions)

	# merge the room floor positions into the main floor_positions dictionary
	floor_positions.merge(room_positions)

	# iterate through each generated corridor
	for i in range(0, corridors.size()):
		# increase the size of each corridor by one (or two) tiles for more variation
		corridors[i] = increase_corridor_size_by_1(corridors[i])
		#corridors[i] = increase_corridor_size_by_3_by_3(corridors[i])

		# add the expanded corridor tiles to the main floor_positions dictionary
		for position in corridors[i]:
			floor_positions[position] = null

	# get the atlas ID for the floor tilemap layer
	var floor_atlas_id : int = floor_tilemap_layer.atlas_id
	# get the position of the base corridor floor tile in the atlas
	var corridor_tile_pos : Vector2i = floor_tilemap_layer.base_corridor_floor_tile_atlas_position

	# get the atlas ID for the wall tilemap layer
	var wall_atlas_id : int = wall_tilemap_layer.atlas_id
	# get the position of the base corridor wall tile in the atlas
	var corridor_wall_tile_pos : Vector2i = wall_tilemap_layer.base_corridor_wall_tile_atlas_position

	# paint the floor tiles
	paint_tiles(floor_positions, floor_tilemap_layer, floor_atlas_id, corridor_tile_pos)
	# create walls around the corridors using the positions stored in floor_positions
	create_walls(floor_positions, wall_tilemap_layer, wall_atlas_id, corridor_wall_tile_pos)

# generates a set of rooms based on a list of potential room positions
# first calculates how many rooms to create based on a percentage from proc_gen_data,
# then randomly selects room positions and generates floor layouts for each room using
# a random walk algorithm. The positions of all floor tiles for the created rooms are 
# stored in the final dictionary and returned.
func create_rooms(potential_room_positions : Dictionary) -> Dictionary:
	# dictionary to store the positions of all the floor tiles for the rooms
	var room_positions : Dictionary = {}

	# calculate how many rooms to create based on the percentage specified in proc_gen_data
	var rooms_to_create_amount = roundi(potential_room_positions.size() * proc_gen_data.room_amount_percent)

	# get an array of the keys (room positions) from the potential_room_positions dictionary
	var rooms : Array = potential_room_positions.keys()

	# shuffle the array of room positions to randomize the selection
	rooms.shuffle()

	# take the first 'rooms_to_create_amount' room positions from the shuffled array
	var rooms_to_create : Array = rooms.slice(0, rooms_to_create_amount)

	# iterate over the selected room positions
	for room_position in rooms_to_create:
		# run the random walk algorithm to generate the floor layout/positions for this room
		var room_floor : Dictionary = run_random_walk(room_position)
		# merge the generated room floor positions into the room_positions dictionary
		room_positions.merge(room_floor)

	# return the final dictionary containing all the positions of the floor tiles for all rooms created
	return room_positions

# finds all dead-end positions in the floor layout
# a dead-end is defined as a floor tile that has only one neighboring floor tile
func find_all_dead_ends(floor_positions : Dictionary) -> Array:
	# array to store all the detected dead-end positions
	var dead_ends : Array = []

	# iterate over each floor tile position in the floor layout
	for position in floor_positions:
		# variable to count the number of neighboring floor tiles for the current position
		var neighbor_count : int = 0

		# check each direction (up, down, left, right) from the current tile
		for direction in proc_gen_data.direction_list:

			# if a neighboring tile exists in the given direction
			if floor_positions.keys().has(position + direction):
				# increment the neighbor count
				neighbor_count += 1

		# if the current tile has only one neighboring floor tile, it's considered a dead-end
		if (neighbor_count == 1):
			# add the position to the dead_ends array
			dead_ends.append(position)

	# return the array of dead-end positions
	return dead_ends

# creates rooms at dead-end positions by performing a random walk starting from each dead-end
# if a dead-end is not already part of an existing room, a room will be generated at that position
func create_rooms_at_dead_ends(dead_ends : Array, room_positions : Dictionary) -> void:
	# iterate over each dead-end position
	for position in dead_ends:

		# if the dead-end position is not already part of an existing room
		if (room_positions.keys().has(position) == false):

			# generate a room (floor positions) using a random walk starting from the dead-end position
			var room : Dictionary = run_random_walk(position)

			# merge the new room's floor positions into the main room_positions dictionary
			room_positions.merge(room)

# expands the given corridor by adding additional tiles around corners and straight sections
# for each corner in the corridor, it adds surrounding tiles, while straight sections get
# an additional tile added in the direction perpendicular to the corridor's direction
func increase_corridor_size_by_1(corridor : Array) -> Array:
	# initialize an array to store the expanded corridor
	var new_corridor : Array = []

	# variable to keep track of the previous direction between corridor tile
	var previous_direction : Vector2i = Vector2i.ZERO

	# loop through each tile in the corridor, starting from the second tile (i = 1)
	for i in range(1, corridor.size()):
		# calculate the direction vector from the previous tile to the current tile
		var direction_between_tiles : Vector2i = corridor[i] - corridor[i - 1]

		# check if there is a change in direction (i.e., a corner)
		if (previous_direction != Vector2i.ZERO and direction_between_tiles != previous_direction):
			# handle corner by adding surronding tiles around the previous tile (the corner)

			# iterate over the direction to all neighboring tiles
			for x in range(-1, 2):
				for y in range(-1, 2):
					# add the surrounding tiles of the previous (corner) tile (including diagonals) to the new corridor
					new_corridor.append(corridor[i - 1] + Vector2i(x, y))

			# update the previous direction for the next iteration
			previous_direction = direction_between_tiles

		else:

			# add a single cell in the current direction + 90 degrees since were not at a corner
			var new_corridor_tile_offset : Vector2i = get_direction_90_degrees_from(direction_between_tiles)

			# add the current tile and the new offset tile to the new corridor
			new_corridor.append(corridor[i]);
			new_corridor.append(corridor[i - 1] + new_corridor_tile_offset);

	# return the expanded corridor with the additional tiles
	return new_corridor

# increases the size of a corridor by expanding each tile in the corridor to a 3x3 area
# for each tile in the corridor, it adds surrounding tiles to create a wider corridor
func increase_corridor_size_by_3_by_3(corridor : Array) -> Array:
	# initialize an array to store the expanded corridor
	var new_corridor : Array = []

	# loop through each tile in the corridor, starting from the second tile (i = 1)
	for i in range(1, corridor.size()):

		# for each tile, create a 3x3 area around it
		for x in range(-1, 2):
			for y in range(-1, 2):
				# add the surrounding tiles (including diagonals) to the new corridor
				new_corridor.append(corridor[i - 1] + Vector2i(x, y))

	# return the newly expanded corridor
	return new_corridor

# returns a vector representing a 90-degree clockwise direction from the given direction
func get_direction_90_degrees_from(direction : Vector2i) -> Vector2i:
	# check if the input direction is UP, and return RIGHT if true
	if direction == Vector2i.UP:
		return Vector2i.RIGHT

	# check if the input direction is RIGHT, and return DOWN if true
	if direction == Vector2i.RIGHT:
		return Vector2i.DOWN

	# check if the input direction is DOWN, and return LEFT if true
	if direction == Vector2i.DOWN:
		return Vector2i.LEFT

	# check if the input direction is LEFT, and return UP if true
	if direction == Vector2i.LEFT:
		return Vector2i.UP

	# if the direction does not match any cardinal direction, return Vector2i.ZERO
	return Vector2i.ZERO

# creates corridors using a random walk algorithm and adds their positions to the set of floor positions
# generates a specified number of corridors
# updating the floor positions and potential room positions as corridors are created.
func create_corridors(floor_positions : Dictionary, potential_room_positions : Dictionary) -> Array[Array]:
	# set the starting position for corridor generation
	var current_position = proc_gen_data.start_position

	# mark the starting position as a potential room position
	potential_room_positions[current_position] = null

	# array to store all the generated corridors
	var corridors : Array[Array] = []

	# loop through the specified corridor amount to generate multiple corridors
	for i in range(0, proc_gen_data.corridor_amount):
		# generate a corridor by executing a random walk from the current position
		var corridor : Array = random_walk_corridor(current_position, proc_gen_data.corridor_walk_length)

		# store the generated corridor in the corridors array
		corridors.append(corridor)

		# set current_position to the last position in the generated corridor (the corridor endpoint)
		current_position = corridor[corridor.size() - 1]

		# mark the end position of the corridor as a potential room position
		potential_room_positions[current_position] = null

		# iterate through each position in the generated corridor
		for position in corridor:
			# include the position in the dictionary of floor positions, marking it as part of the floor layout
			floor_positions[position] = null

	# return the array of generated corridors
	return corridors

# generates a random walk corridor starting from a specified position
# creates a corridor by moving in a random direction for a given length
func random_walk_corridor(start_position : Vector2i, corridor_length : int) -> Array:
	# array to store the positions of the corridor tiles
	var corridor : Array = []

	# get a random direction for the corridor movement
	var direction = get_random_direction()

	# set the current position to the starting position
	var current_position = start_position

	# add the current position to the corridor tile list
	corridor.append(current_position)

	# iterate for the specified length of the corridor
	for i in range(0, corridor_length):
		# move to the next position in the current direction
		current_position += direction

		# add the new position to the corridor array
		corridor.append(current_position)

	# return the array containing all positions of the corridor tiles
	return corridor





# Room First Generation

# generates rooms using binary space partitioning (BSP), creates simple rooms from the partitions, 
# and paints the floor tiles for these rooms onto a tilemap
# it also places walls around the generated rooms
func room_first_generation() -> Array[Dictionary]:
	# clear any existing tiles in the floor, staircase, wall tilemaps before generating new ones
	clear_tiles(floor_tilemap_layer)
	clear_tiles(wall_tilemap_layer)
	clear_tiles(staircase_tilemap_layer)
	clear_tiles(door_tilemap_layer)

	# array to store information about each room in the game
	# Each room is represented as a Dictionary with the following key-value pairs:
	# - "center": The center position of the room (Vector2i).
	# - "aabb": The Axis-Aligned Bounding Box of the room (AABB).
	# - "floor_positions": The tile positions of the room stored in the keys of a (Dictionary)
	# - "type": The type/category of the room (can be null initially).
	# - "next_room": Reference to the center position of next room (null if none).
	# - "prev_room": Reference to the center position of previous room (null if none).
	# - "entrance": Boolean indicating if the room is the first room (default: false).
	# - "exit": Boolean indicating if the room is the last room (default: false).
	var rooms_dict_array : Array[Dictionary] = []

	# offset the dungeon's origin is by half its width and height to ensure 
	# the entire dungeon it is center aligned
	var room_start_position : Vector2i = Vector2i(
		-proc_gen_data.dungeon_width / 2, 
		-proc_gen_data.dungeon_height / 2
	)

	# generate a list of rooms using binary space partitioning (BSP)
	# the AABB defines the entire dungeon space to be split, using the dungeon start position and dimensions
	# the min width and height for rooms are passed to control how small the rooms can get during splitting
	var rooms_list : Array[AABB] = binary_space_partitioning(
		AABB(
			Vector3i(room_start_position.x, room_start_position.y, 0),
			Vector3i(proc_gen_data.dungeon_width, proc_gen_data.dungeon_height, 0)
		),
		proc_gen_data.min_room_width,
		proc_gen_data.min_room_height
		)
	
	#print(rooms_list, "\n")

	var new_rooms_list = bsp_new(
		Rect2(Vector2i(room_start_position.x, room_start_position.y), Vector2i(proc_gen_data.dungeon_width, proc_gen_data.dungeon_height)),
		proc_gen_data.min_room_width,
		proc_gen_data.min_room_height
		)

	print(new_rooms_list)

	var roooooms : Array[AABB] = []
	for node in new_rooms_list:
		var room = AABB(Vector3i(node.room.position.x, node.room.position.y, 0), Vector3i(node.room.size.x, node.room.size.y, 0))
		roooooms.append(room)
	#var new_room_list = []
	#for room in rooms_list:
		#var rect = Rect2(Vector2i(room.position.x, room.position.y), Vector2i(room.size.x, room.size.y))
		#new_room_list.append(rect)
		#
	#print(new_room_list)

	# dictionary to hold the floor tiles for the generated rooms
	var floor_tiles : Dictionary = {}

	# check if random walk room generation is enabled
	if (proc_gen_data.random_walk_room):
		# generate rooms using a random walk algorithm
		# the room data is populated in the 'rooms_dict_array' for further processing
		create_random_walk_rooms(roooooms, rooms_dict_array, floor_tiles)
	else:
		# create simple rooms by converting the AABB rooms into floor tiles stored in a dictionary
		floor_tiles = create_simple_rooms(rooms_list)

	# finds the closest room center and creates corridors between them
	# store all the resulting corridor tiles in a dictionary for later use
	var corridors : Dictionary = connect_rooms(rooms_dict_array)

	# merge the corridor tiles into the floor tiles dictionary
	floor_tiles.merge(corridors)

	# get the atlas ID for the floor tilemap layer
	var floor_atlas_id : int = floor_tilemap_layer.atlas_id
	# get the position of the base corridor floor tile in the atlas
	var corridor_tile_pos : Vector2i = floor_tilemap_layer.base_corridor_floor_tile_atlas_position

	# get the atlas ID for the wall tilemap layer
	var wall_atlas_id : int = wall_tilemap_layer.atlas_id
	# get the position of the base corridor wall tile in the atlas
	var corridor_wall_tile_pos : Vector2i = wall_tilemap_layer.base_corridor_wall_tile_atlas_position

	# paint the floor tiles
	paint_tiles(floor_tiles, floor_tilemap_layer, floor_atlas_id, corridor_tile_pos)
	# create walls around the corridors using the positions stored in floor_positions
	create_walls(floor_tiles, wall_tilemap_layer, wall_atlas_id, corridor_wall_tile_pos)

	# get the dictionary containing all the data for the exit room
	var exit_room : Dictionary = get_exit_room_dict(rooms_dict_array)

	# add one staircase to the exit room at a random position
	add_tile_at_random_positions(
		exit_room["floor_positions"], 
		1, 
		staircase_tilemap_layer, 
		staircase_tilemap_layer.atlas_id, 
		staircase_tilemap_layer.upward_staircase_tile_atlas_position
	)

	for room_dict in rooms_dict_array:
		if room_dict.has("outgoing_corridor") && room_dict["outgoing_corridor"] != null:
			var outgoing_corridor : Array = room_dict["outgoing_corridor"]
			var door_position  : Vector2i
			var current_floor : Dictionary = room_dict["floor_positions"]
			var next_floor : Dictionary = {}
			var next_center = room_dict["next_room"]
			var corridor_exclusive_tiles : Array = []
			for room_dict_i in rooms_dict_array:
				if room_dict_i["center"] == next_center:
					next_floor = room_dict_i["floor_positions"]

			#print(room_dict["floor_positions"].keys())

			for position in outgoing_corridor:
				if !current_floor.keys().has(position) && !next_floor.keys().has(position):
					corridor_exclusive_tiles.append(position)

			#print(corridor_exclusive_tiles, "\n")

			door_position = corridor_exclusive_tiles[corridor_exclusive_tiles.size() / 2]
			paint_single_tile(door_tilemap_layer, door_tilemap_layer.atlas_id, door_position, door_tilemap_layer.door_tile_atlas_position)

			#for position in outgoing_corridor:
				#if !room_dict["floor_positions"].keys().has(position):
					#door_position = position
					#paint_single_tile(door_tilemap_layer, door_tilemap_layer.atlas_id, door_position, door_tilemap_layer.door_tile_atlas_position)
					#break

	return rooms_dict_array

func get_exit_room_dict(rooms_dict_array : Array[Dictionary]) -> Dictionary:
	for room_dict in rooms_dict_array:
		if room_dict["exit"] == true:
			return room_dict
	return {}

func add_tile_at_random_positions(floor_tiles : Dictionary, iterations : int, tilemap_layer : TileMapLayer, tilemap_layer_atlas_id : int, tile_atlas_position : Vector2i):
	var random_floor_position_array : Array = floor_tiles.keys()
	randomize()
	random_floor_position_array.shuffle()
	
	for i in range(0, iterations):
		var random_position : Vector2i = random_floor_position_array[i]
		
		# paint the tile at the chosen random position in the given tilemap layer
		paint_single_tile(tilemap_layer, tilemap_layer_atlas_id, random_position, tile_atlas_position)

# generates floor positions within defined rooms using a random walk algorithm
# each room's center is used as the starting point for the random walk, and 
# positions generated are validated to ensure they fall within the room's bounds
func create_random_walk_rooms(rooms_list : Array[AABB], rooms_dict_array : Array[Dictionary], floor_tiles : Dictionary):
	# iterate over each room defined in the rooms_list
	for i in range(0, rooms_list.size()):

		# get the current AABB room from the rooms_list
		var room : AABB = rooms_list[i]

		# calculate the center of the current room
		var room_center : Vector2i = Vector2i(round(room.get_center().x), round(room.get_center().y))

		# run the random walk algorithm starting from the room center
		var room_floor_positions : Dictionary = run_random_walk(room_center)

		# dictionary to hold valid room floor tiles
		var valid_floor_positions : Dictionary = {}

		# check each position generated by the random walk
		for position in room_floor_positions:

			# calculate the x,y position of the edges of the room 
			var left_edge : int = room.position.x
			var right_edge : int = room.position.x + room.size.x
			var top_edge : int = room.position.y
			var bottom_edge : int = room.position.y + room.size.y

			# get the room offset
			var offset : int = proc_gen_data.room_offset

			# ensure the position is within the valid bounds of the room,
			# accounting for the room_offset
			if (
				position.x >= left_edge + offset &&
				position.x <= right_edge - offset &&
				position.y >= top_edge + offset &&
				position.y <= bottom_edge - offset
				):

				# if the position is valid, add it to the valid floor positions dictionary
				valid_floor_positions[position] = null

		# merge the valid floor positions into the overall floor positions dictionary
		floor_tiles.merge(valid_floor_positions)

		# create a dictionary to store room details
		var room_dict : Dictionary = {
			"center": room_center,
			"aabb": room,
			"floor_positions": valid_floor_positions,
			"outgoing_corridor" : null,
			"incoming_corridor" : null,
			"type": null,
			"next_room": null,
			"prev_room": null,
			"entrance": false,
			"exit": false
		}

		# append the room dictionary to the rooms dictionary array
		rooms_dict_array.append(room_dict)

# connects rooms by creating corridors between their centers
# the rooms are represented by their center points, and the corridors 
# are stored in a dictionary where each key is a tile position along the corridor
func connect_rooms(rooms_dict_array : Array[Dictionary]) -> Dictionary:
	# dictionary to store all the corridor tiles
	var corridors : Dictionary = {}

	# array to store the center positions of each room
	var room_centers: Array = []

	# collect all room centers from the rooms dictionary array
	for room_dict in rooms_dict_array:
		room_centers.append(room_dict["center"])

	# pick a random room center to start with
	var current_room_center : Vector2i = room_centers[0]

	# mark the starting room
	for room_dict in rooms_dict_array:
		if room_dict["center"] == current_room_center:
			room_dict["entrance"] = true
			break

	# remove the selected room center from the list to avoid reconnecting it
	room_centers.erase(current_room_center)

	# loop until all room centers have been connected
	while room_centers.size() > 0:
		# find the closest room center to the current room center
		var closest_center : Vector2i = find_closest_room_center(current_room_center, room_centers)

		# if only one room center remains, mark it as the exit
		if room_centers.size() == 1:
			for room_dict in rooms_dict_array:
				if room_dict["center"] == closest_center:
					room_dict["exit"] = true
					break

		# remove the closest room center from the list to avoid reconnecting it
		room_centers.erase(closest_center)

		# create a new corridor between the current room center and the closest center using straight lines
		var new_corridor : Array = create_corridor(current_room_center, closest_center)

		# Optionally, create a new corridor between the current room center and the closest center using diagnol lines
		#var new_corridor : Dictionary = create_diagnol_corridor(current_room_center, closest_center)

		# increase the size of the newly created corridor by padding each tile with a 3x3 grid
		#var new_padded_corridor : Array = increase_corridor_size_by_3_by_3(new_corridor.keys())

		# Optionally, add the padded corridor tile to the corridor tiles ditionary
		#for tile in new_padded_corridor:
			#corridors[tile] = null

		# update the next room reference for the current room
		for room_dict in rooms_dict_array:
			if room_dict["center"] == current_room_center:
				room_dict["outgoing_corridor"] = new_corridor
				room_dict["next_room"] = closest_center
			# update the previous room reference for the closest room
			elif room_dict["center"] == closest_center:
				var reversed_corridor : Array = new_corridor.duplicate(true)
				reversed_corridor.reverse()
				room_dict["incoming_corridor"] = reversed_corridor
				room_dict["prev_room"] = current_room_center

		

		# move to the closest room center to continue the process
		current_room_center = closest_center

		# merge the new corridor tiles into the corridor tiles dictionary
		for position in new_corridor:
			corridors[position] = null

	# return the dictionary containing all the corridor tiles connecting the rooms
	return corridors

# find the closest room center to the current room center from a list of room centers
# calculates the distance between the current room center and each center in the list,
# and returns the one with the smallest distance
func find_closest_room_center(current_room_center : Vector2i, room_centers : Array) -> Vector2i:
	# intialize the closest room center with a default value (Vector2i.ZERO)
	var closest_room_center : Vector2i = Vector2i.ZERO

	# initialize the minimum distance to infinity to ensure any calculated distance will be smaller
	var distance_to_room_center : float = INF

	# iterate through the room centers list to find the closest one
	for center in room_centers:

		# calculate the distance between the current room center and the current center in the list
		var current_distance_to_center : float = center.distance_to(current_room_center)

		# if the distance to the current room center is less than the previously tracked minimum distance,
		# update the closest room center and record the new shortest distance
		if current_distance_to_center < distance_to_room_center:

			# update the minimum distance with the new shortest distance found
			distance_to_room_center = current_distance_to_center

			# set the closest room center to the room with the shortest distance
			closest_room_center = center

	# return the closest room center found
	return closest_room_center

# creates a corridor between the start and end positions
# the corridor is represented as a dictionary where each tile position is a key
func create_corridor(start_position : Vector2i, end_position : Vector2i) -> Array:
	# array to store the positions of corridor tiles
	var corridor : Array = []

	# set the current position to the starting point of the corridor
	var current_position : Vector2i = start_position

	# add the initial start position to the corridor array
	corridor.append(current_position)

	# move vertically until the current position's y matches the end position's y
	while current_position.y != end_position.y:

		# if the end position is above the current position, move up
		if end_position.y > current_position.y:
			current_position += Vector2i.DOWN;

		# if the end position is below the current position, move down
		elif end_position.y < current_position.y:
			current_position += Vector2i.UP;

		# add the new position to the corridor array
		corridor.append(current_position)

	# move horizontally until the current position's x matches the end position's x
	while current_position.x != end_position.x:

		# if the end position is to the right of the current position, move right
		if end_position.x > current_position.x:
			current_position += Vector2i.RIGHT;

		# if the end position is to the left of the current position, move left
		elif end_position.x < current_position.x:
			current_position += Vector2i.LEFT;

		# add the new position to the corridor array
		corridor.append(current_position)

	# return the dictionary containing all the positions of the corridor tiles
	return corridor

# creates simple rectangular rooms from a list of AABB room objects
# generates a floor layout for each room and stores the floor tiles in a dictionary
# the resulting dictionary contains positions of the floor tiles, where each room's floor 
# is generated within its bounds, excluding some offsets for walls or other decorations
func create_simple_rooms(rooms_list : Array[AABB]) -> Dictionary:
	# to decorate rooms procedural, save each floor room in sperate dict and process further

	# dictionary to store all the floor tile positions for each room
	var floor : Dictionary = {}

	# validate the room offset to ensure it doesn't make rooms smaller than allowed
	# if the offset is too large, it is adjusted to fit within valid constraints
	proc_gen_data.room_offset = validate_room_offset()

	# loop through each room in the rooms list
	for room in rooms_list:

		# iterate through the room's dimensions, applying an offset to leave space for walls or decorations
		# the offsets prevent the floor from being created all the way to the other room's edges
		for col in range(proc_gen_data.room_offset, room.size.x - proc_gen_data.room_offset):
			for row in range(proc_gen_data.room_offset, room.size.y - proc_gen_data.room_offset):

				# calculate the tile's position by adding the room's position and the current offset
				var position : Vector2i = Vector2i(room.position.x, room.position.y) + Vector2i(col, row)

				# store the position as a floor tile in the dictionary
				floor[position] = null

	# return the dictionary containing all the floor tile positions for the rooms
	return floor

# validate the room offset to ensure it doesn't make the room size 0 or negative
# if the offset is too large, it is adjusted to fit within valid constraints
func validate_room_offset() -> int:
	# get the current room offset value	
	var offset : int = proc_gen_data.room_offset

	# get the smaller dimension between the minimum room width and height
	var min_of_room_width_and_height : int = min(proc_gen_data.min_room_width, proc_gen_data.min_room_height)

	# variable to store the offset status
	var offset_status : float = 0

	# check if the offset is greater than 0
	if offset > 0:
		# calculate the status to ensure the room size won't result in a negative or size zero room
		offset_status = (min_of_room_width_and_height as float) / (offset * 2)

	# if the offset status is valid (greater than 1 or 0), meaning it does not result
	# in a room of negative or zero size, return the current offset
	if offset_status > 1 or offset == 0: 
		return offset

	# if the offset is too large, adjust it to ensure valid room size and return the adjusted offset
	return (min_of_room_width_and_height / 2) - 1

# performs binary space partitioning on a given space to create a list of rooms
# algorithm recursively splits the space until the resulting rooms meet
# the minimum width and height requirements
func binary_space_partitioning(space_to_split : AABB, min_room_width: int, min_room_height: int) -> Array[AABB]:
	# array to store the created rooms
	var rooms_list : Array[AABB] = []

	split_room(space_to_split, rooms_list, min_room_width, min_room_height)

	return rooms_list

func split_room(room, rooms_list, min_room_width, min_room_height):
	var px : int = room.position.x
	var py : int = room.position.y
	var sx : int = room.size.x
	var sy : int = room.size.y

	var split : float
	var room_1 : AABB
	var room_2 : AABB

	if (sx < min_room_width) && (sy < min_room_height):
		rooms_list.append(room)
		return

	var random_split : float = randf() >= 0.5

	if random_split && sy >= (min_room_height * 2):
		# split horizontal

		if proc_gen_data.bsp_random_splits == true:
			split = randf_range(1, sy)
		else:
			split = randi_range(min_room_height, sy - min_room_height)

		room_1 = AABB(room.position, Vector3i(sx, split, 0))
		room_2 = AABB(Vector3i(px, py + split, 0), Vector3i(sx, sy - split, 0))

	elif sx >= (min_room_width * 2):
		# split vertical

		if proc_gen_data.bsp_random_splits == true:
			split = randf_range(1, sx)
		else:
			split = randi_range(min_room_width, sx - min_room_width)

		room_1 = AABB(room.position, Vector3i(split, sy, 0))
		room_2 = AABB(Vector3i(px + split, py, 0), Vector3i(sx - split, sy, 0))

	else:
		rooms_list.append(room)
		return

	split_room(room_1, rooms_list, min_room_width, min_room_height)
	split_room(room_2, rooms_list, min_room_width, min_room_height)

# creates a diagonal corridor between two points using Bresenham's line algorithm
# the corridor is represented as a dictionary where the keys are positions (Vector2i) 
# that form a path from the start to the end position
func create_diagnol_corridor(start_position : Vector2i, end_position : Vector2i) -> Dictionary:
	# dictionary to hold the positions that make up the corridor
	var corridor : Dictionary = {}

	# get the x and y coordinates from start and end positions
	var x0 : int = start_position.x
	var y0 : int = start_position.y
	var x1 : int = end_position.x
	var y1 : int = end_position.y

	# calculate differences in x and y direction
	var dx : int = abs(x1-x0)
	var dy : int = abs(y1-y0)

	# determine the step direction for x and y (whether to increment or decrement)
	var sx : int
	var sy : int

	# set x direction step: -1 if moving left, 1 if moving right
	if x0 > x1:
		sx = -1
	else:
		sx = 1

	# set y direction step: -1 if moving up, 1 if moving down
	if y0 > y1:
		sy = -1
	else:
		sy = 1

	# initial error term for Bresenham's algorithm (difference between x and y)
	var err : int = dx-dy

	# loop until the current position matches the end position
	while true:
		# mark the current position in the corridor dictionary
		corridor[Vector2i(x0,y0)] = null

		# break the loop once the start and end positions match
		if x0 == x1 and y0 == y1:
			break

		# calculate a temporary error term to adjust movement direction
		var e2 : int = 2 * err

		# move horizontally if necessary
		if e2 > -dy:
			# adjust the error term for horizontal movement
			err -= dy
			# adjust x-coordinate based on the step direction
			x0 += sx

		# move vertically if necessary
		if e2 < dx:
			# adjust the error term for vertical movement
			err += dx
			# adjust y-coordinate based on the step direction
			y0 += sy

	# return the dictionary containing all the positions of the diagonal corridor
	return corridor





class RoomNode:
	var left : RoomNode = null
	var right : RoomNode = null
	var room : Rect2 = Rect2()
	var is_leaf : bool = false
	var center : Vector2i = Vector2i()
	var room_tiles : Dictionary = {}
	var outgoing_corridor : Array = []
	var incoming_corridor : Array = []
	var room_type = null
	var next_room : RoomNode = null
	var prev_room : RoomNode = null
	var is_entrance : bool = false
	var is_exit : bool = false

	func _init(room : Rect2):
		self.room = room

	func has_outgoing_corridor():
		return outgoing_corridor.size() > 0

	func has_center(c):
		return c == center

	func trim(trim_amount):
		room.position.x += trim_amount
		room.position.y += trim_amount
		room.size.x -= 2 * trim_amount
		room.size.y -= 2 * trim_amount
		
		if left != null:
			left.trim(trim_amount)
		if right != null:
			right.trim(trim_amount)

func start_level() -> void:
	var room_nodes = []
	var valid_generation = room_first_gen(room_nodes)
	
	if (!valid_generation):
		print("retry")
		start_level()
		return
	else:
		generated_rooms = room_nodes
		for room_node in room_nodes:
			if room_node.is_entrance:
				var floor_positions : Array = room_node.room_tiles.keys()
				var spawn_tile_position = floor_positions.pick_random()
				var spawn_global_position = floor_tilemap_layer.map_to_local(spawn_tile_position)
				player.position = spawn_global_position
				player.visible = true
				dungeon_created = true
				break

func bsp_new(space_to_split : Rect2, min_room_width: int, min_room_height: int) -> RoomNode:
	var root = RoomNode.new(space_to_split)

	split(root, min_room_width, min_room_height)

	return root

func collect_leaf_nodes_level_order(root, leaves):
	if root == null:
		return
	if root.left == null && root.right == null:
		leaves.append(root)
		return
	else:
		collect_leaf_nodes_level_order(root.left, leaves)
		collect_leaf_nodes_level_order(root.right, leaves)

func collect_leaf_nodes_DFS(root, leaves):
	if root == null:
		return
	if root.left == null && root.right == null:
		leaves.append(root)
		return
	
	if root.left != null:
		collect_leaf_nodes_DFS(root.left, leaves)
	if root.right != null:
		collect_leaf_nodes_DFS(root.right, leaves)

func level_order_traversal(root: RoomNode):
	if root == null:
		return

	# Initialize a queue with the root node
	var queue = []
	var node
	queue.append(root)

	# While there are nodes in the queue
	while queue.size() > 0:
	# Pop the first node from the queue
		node = queue.pop_front()
		#print("(", node.room.position.x, ",", node.room.position.y, ")")
		print(node.room)

		# Add the left child to the queue if it exists
		if node.left != null:
			queue.append(node.left)

		# Add the right child to the queue if it exists
		if node.right != null:
			queue.append(node.right)

func height(node):
	if node == null:
		return 0
	else:

		# compute the height of each subtree
		var lheight = height(node.left)
		var rheight = height(node.right)

		# use the larger one
		return (lheight + 1) if lheight > rheight else (rheight + 1)

func get_given_level(root, level, levelNodes):
	if root == null:
		return
	if level == 1:
		levelNodes.append(root)
	elif level > 1:
		get_given_level(root.left, level - 1, levelNodes)
		get_given_level(root.right, level - 1, levelNodes)

func levelOrder(root):
	var result = []
	var h = height(root)
	for i in range(1, h + 1):
		var levelNodes = []
		get_given_level(root, i, levelNodes)
		result.append(levelNodes)
	return result

func split(node, min_room_width, min_room_height):
	var px : int = node.room.position.x
	var py : int = node.room.position.y
	var sx : int = node.room.size.x
	var sy : int = node.room.size.y

	var split : float
	var room_1_rect : Rect2 
	var room_2_rect : Rect2
	var room_1 : RoomNode
	var room_2 : RoomNode

	if (sx < min_room_width) && (sy < min_room_height):
		node.is_leaf = true
		return

	var random_split : float = randf() >= 0.5

	if random_split && sy >= (min_room_height * 2):
		# split horizontal

		if proc_gen_data.bsp_random_splits == true:
			split = randf_range(1, sy)
		else:
			split = randi_range(min_room_height, sy - min_room_height)

		room_1_rect = Rect2(node.room.position, Vector2i(sx, split))
		room_2_rect = Rect2(Vector2i(px, py + split), Vector2i(sx, sy - split))

	elif sx >= (min_room_width * 2):
		# split vertical

		if proc_gen_data.bsp_random_splits == true:
			split = randf_range(1, sx)
		else:
			split = randi_range(min_room_width, sx - min_room_width)

		room_1_rect = Rect2(node.room.position, Vector2i(split, sy))
		room_2_rect = Rect2(Vector2i(px + split, py), Vector2i(sx - split, sy))

	else:
		node.is_leaf = true
		return
		
	if (node.left == null):
		node.left = RoomNode.new(room_1_rect)
	if (node.right == null):
		node.right = RoomNode.new(room_2_rect)

	split(node.left, min_room_width, min_room_height)
	split(node.right, min_room_width, min_room_height)

func room_first_gen(room_nodes):
	clear_tiles(floor_tilemap_layer)
	clear_tiles(wall_tilemap_layer)
	clear_tiles(staircase_tilemap_layer)
	clear_tiles(door_tilemap_layer)

	var rooms_dict_array : Array[RoomNode] = []

	var room_start_position : Vector2i = Vector2i(-proc_gen_data.dungeon_width / 2, -proc_gen_data.dungeon_height / 2)

	var root = bsp_new(
		Rect2(Vector2i(room_start_position.x, room_start_position.y), Vector2i(proc_gen_data.dungeon_width, proc_gen_data.dungeon_height)),
		proc_gen_data.min_room_width,
		proc_gen_data.min_room_height
		)

	collect_leaf_nodes_DFS(root, room_nodes)

	if (proc_gen_data.random_walk_room):
		create_rooms_using_random_walk(room_nodes)
	#else:
		#all_room_floor_tiles = create_simple_rooms(rooms_list)
	
	if (!connect_rooms_2(room_nodes)):
		return false

	if !add_doors_to_corridors(room_nodes):
		return false
	
	var all_floor_tiles = get_all_tiles(room_nodes)

	#var leaves = []
	#collect_leaf_nodes_level_order(root, leaves)
	#
	#var rooms = []
	#for leaf in leaves:
		#rooms.append(Rect2(Vector2i(leaf.room.position.x + 100, leaf.room.position.y + 100), leaf.room.size))
	#
	#room_draw_testing_script.set_room_list(rooms)
	#
	#root.trim(1)
	#
	#leaves = []
	#collect_leaf_nodes_level_order(root, leaves)
	#rooms = []
	#for leaf in leaves:
		#rooms.append(Rect2(Vector2i(leaf.room.position.x + 100, leaf.room.position.y + 100), leaf.room.size))
	#
	#room_draw_testing_script.set_room_list(rooms)

	# get the atlas ID for the floor tilemap layer
	var floor_atlas_id : int = floor_tilemap_layer.atlas_id
	# get the position of the base corridor floor tile in the atlas
	var corridor_tile_pos : Vector2i = floor_tilemap_layer.base_corridor_floor_tile_atlas_position

	# get the atlas ID for the wall tilemap layer
	var wall_atlas_id : int = wall_tilemap_layer.atlas_id
	# get the position of the base corridor wall tile in the atlas
	var corridor_wall_tile_pos : Vector2i = wall_tilemap_layer.base_corridor_wall_tile_atlas_position

	# paint the floor tiles
	paint_tiles(all_floor_tiles, floor_tilemap_layer, floor_atlas_id, corridor_tile_pos)
	# create walls around the corridors using the positions stored in floor_positions
	create_walls(all_floor_tiles, wall_tilemap_layer, wall_atlas_id, corridor_wall_tile_pos)

	var exit_room_node
	for room_node in room_nodes:
		if room_node.is_exit:
			exit_room_node = room_node

	# add one staircase to the exit room at a random position
	
	generate_exit(exit_room_node.room_tiles)
	
	return true

func generate_exit(exit_room_tiles):
	var random_floor_position_array : Array = exit_room_tiles.keys()
	randomize()
	random_floor_position_array.shuffle()

	var random_position : Vector2i = random_floor_position_array[0]
	
	exit_location = random_position

	# paint the tile at the chosen random position in the given tilemap layer
	paint_single_tile(staircase_tilemap_layer, staircase_tilemap_layer.atlas_id, random_position, staircase_tilemap_layer.upward_staircase_tile_atlas_position)

func add_doors_to_corridors(room_nodes):
	for room_node in room_nodes:
		if room_node.has_outgoing_corridor():
			var outgoing_corridor : Array = room_node.outgoing_corridor
			var door_position  : Vector2i
			var current_floor : Dictionary = room_node.room_tiles
			var next_floor : Dictionary = {}
			var next_center = room_node.next_room.center
			var corridor_exclusive_tiles : Array = []
			for room_node_i in room_nodes:
				if room_node_i.has_center(next_center):
					next_floor = room_node_i.room_tiles

			#print(room_dict["floor_positions"].keys())

			for tile in outgoing_corridor:
				if !current_floor.keys().has(tile) && !next_floor.keys().has(tile):
					corridor_exclusive_tiles.append(tile)

			if corridor_exclusive_tiles.size() == 0:
				print("WIRED DORROROR")
				return false

			door_position = corridor_exclusive_tiles[corridor_exclusive_tiles.size() / 2]
			paint_single_tile(door_tilemap_layer, door_tilemap_layer.atlas_id, door_position, door_tilemap_layer.door_tile_atlas_position)

			#for position in outgoing_corridor:
				#if !room_dict["floor_positions"].keys().has(position):
					#door_position = position
					#paint_single_tile(door_tilemap_layer, door_tilemap_layer.atlas_id, door_position, door_tilemap_layer.door_tile_atlas_position)
					#break
	return true

func create_rooms_using_random_walk(room_nodes):
	for i in range(0, room_nodes.size()):
		var room : Rect2 = room_nodes[i].room

		# get the roguh center of the current room
		var room_center : Vector2i = Vector2i(round(room.get_center().x), round(room.get_center().y))

		# update the room nodes center
		room_nodes[i].center = room_center

		# run the random walk algorithm starting from the room center
		var room_floor_positions : Dictionary = run_random_walk(room_center)

		# dictionary to hold valid room floor tiles within the bounds of the room
		var valid_floor_positions : Dictionary = {}

		# check each position generated by the random walk
		for position in room_floor_positions:

			# calculate the x,y position of the edges of the room 
			var left_edge : int = room.position.x
			var right_edge : int = room.position.x + room.size.x
			var top_edge : int = room.position.y
			var bottom_edge : int = room.position.y + room.size.y

			# ensure the position is within the valid bounds of the room,
			if (position.x >= left_edge && position.x <= right_edge&& position.y >= top_edge && position.y <= bottom_edge):

				# if the position is valid, add it to the valid floor positions dictionary
				valid_floor_positions[position] = null
		
		room_nodes[i].room_tiles = valid_floor_positions

func connect_rooms_2(room_nodes) -> bool:
	var all_corridor_tiles = {}
	
	# dictionary to store all the corridor tiles
	var corridors : Dictionary = {}

	# array to store the center positions of each room
	var room_centers: Array[Vector2i] = []

	# collect all room centers from the rooms dictionary array
	for room_node in room_nodes:
		room_centers.append(room_node.center)

	# pick the first center to start with
	var current_room_center : Vector2i = room_centers[0]

	# mark the starting room
	for room_node in room_nodes:
		if room_node.has_center(current_room_center):
			room_node.is_entrance = true
			break

	# remove the selected room center from the list to avoid reconnecting it
	room_centers.erase(current_room_center)

	# loop until all room centers have been connected
	while room_centers.size() > 0:
		# find the closest room center to the current room center
		var closest_center : Vector2i = find_closest_room_center(current_room_center, room_centers)

		# if only one room center remains, mark it as the exit
		if room_centers.size() == 1:
			for room_node in room_nodes:
				if room_node.has_center(closest_center):
					room_node.is_exit = true
					break

		# remove the closest room center from the list to avoid reconnecting it
		room_centers.erase(closest_center)

		# create a new corridor between the current room center and the closest center using straight lines
		var new_corridor : Array = create_corridor(current_room_center, closest_center)

		for tile in new_corridor:
			if all_corridor_tiles.keys().has(tile):
				return false
			else:
				if tile != current_room_center && tile != closest_center:
					all_corridor_tiles[tile] = null

		# Optionally, create a new corridor between the current room center and the closest center using diagnol lines
		#var new_corridor : Dictionary = create_diagnol_corridor(current_room_center, closest_center)

		# increase the size of the newly created corridor by padding each tile with a 3x3 grid
		#var new_padded_corridor : Array = increase_corridor_size_by_3_by_3(new_corridor.keys())

		# Optionally, add the padded corridor tile to the corridor tiles ditionary
		#for tile in new_padded_corridor:
			#corridors[tile] = null

		# update the next room reference for the current room
		for room_node in room_nodes:
			if room_node.has_center(current_room_center):
				room_node.outgoing_corridor = new_corridor
				for room_node_i in room_nodes:
					if room_node_i.has_center(closest_center):
						room_node.next_room = room_node_i

			# update the previous room reference for the closest room
			elif room_node.has_center(closest_center):
				var reversed_corridor : Array = new_corridor.duplicate(true)
				reversed_corridor.reverse()
				room_node.incoming_corridor = reversed_corridor
				for room_node_i in room_nodes:
					if room_node_i.has_center(current_room_center):
						room_node.prev_room = room_node_i

		# move to the closest room center to continue the process
		current_room_center = closest_center
	return true

func get_all_tiles(room_nodes) -> Dictionary:
	var all_tiles = {}
	for room_node in room_nodes:
		if room_node.has_outgoing_corridor():
			for tile in room_node.outgoing_corridor:
				all_tiles[tile] = null
		all_tiles.merge(room_node.room_tiles)
	return all_tiles

func player_entered_staircase(player_global_position):
	var player_tile_position = staircase_tilemap_layer.local_to_map(player_global_position)
	if (player_tile_position == exit_location):
		return true
	return false

func _physics_process(delta: float) -> void:
	if dungeon_created:
		if player_entered_staircase(player.global_position):
			print("PLAYER ENTERED STAIRS")

@export var room_draw_testing_script : RoomDrawTesting
