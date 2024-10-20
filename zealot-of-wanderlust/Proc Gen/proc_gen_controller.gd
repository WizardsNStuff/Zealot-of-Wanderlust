extends Node
class_name ProcGenController

# holds the procedural generation settings
@export var proc_gen_data : ProcGenData

# the tilemap layer for the floor
@export var floor_tilemap_layer : FloorTileMapLayer

# the tilemap layer for the walls
@export var wall_tilemap_layer : WallTileMapLayer

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

func increase_corridor_size_by_1(corridor : Array) -> Array:
	return []

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
