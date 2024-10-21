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

# performs binary space partitioning on a given space to create a list of rooms
# algorithm recursively splits the space until the resulting rooms meet
# the minimum width and height requirements
func binary_space_partitioning(space_to_split : AABB, minWidth: int, minHeight: int) -> Array[AABB]:
	# queue to hold the spaces that need to be split
	var rooms_queue : Array[AABB] = []
	# array to store the successfully created rooms
	var rooms_list : Array[AABB] = []

	# enqueue the initial space to split
	rooms_queue.push_back(space_to_split)

	# process the queue until all spaces have been handled
	while (rooms_queue.size() > 0):
		# dequeue the next room to process
		var room : AABB = rooms_queue.pop_front()

		# check if the room is large enough to split
		if (room.size.y >= minHeight && room.size.x >= minWidth):

			# generate a random value to decide how to split the room, for a more random room layout
			# if the random value is <= 0.5, we prioritize a horizontal split
			if (randf() <= 0.5):

				# if the room's height is at least double the min height
				# split the room horizontally to create two new rooms
				if (room.size.y >= minHeight*2):
					split_horizontally(minHeight, rooms_queue, room)

				# if the room's width is at least double the min width
				# split the room vertically to create two new rooms
				elif (room.size.x >= minWidth*2):
					split_vertically(minWidth, rooms_queue, room)

				# the room cannot be split further due to size constraints
				# but it is a valid room, so we add it to the rooms list
				else:
					rooms_list.append(room)

			# if the random value is > 0.5, we prioritize a vertical split
			else:

				# if the room's width is at least double the min width
				# split the room vertically to create two new rooms
				if (room.size.x >= minWidth*2):
					split_vertically(minWidth, rooms_queue, room)

				# if the room's height is at least double the min height
				# split the room horizontally to create two new rooms
				elif (room.size.y >= minHeight*2):
					split_horizontally(minHeight, rooms_queue, room)

				# the room cannot be split further due to size constraints
				# but it is a valid room, so we add it to the rooms list
				else:
					rooms_list.append(room)

	# return the list of created rooms
	return rooms_list

# splits a given room vertically, creating two new rooms
func split_vertically(_minWidth : int, rooms_queue : Array[AABB], room : AABB) -> void:
	# generate a random split position along the width of the room
	var x_split : float = randf_range(1, room.size.x)

	# using a split range of (minWidth, room.size.x - minWidth) ensures we always fit 2 
	# rooms but this creates a grid like structure which looks less random
	#var x_split : float = randf_range(minWidth, room.size.x - minWidth)

	# room_1 is defined by the original room's position (bottom-left corner)
	# and extends horizontally from the start of the room to the x_split point
	# while the height remains the same as the original room
	var room_1 : AABB = AABB(room.position, Vector3i(x_split, room.size.y, room.size.z))

	# room_2 is defined by the position that starts just after the x_split point
	# and extends to the right side of the original room
	# while the height remains the same as the original room
	var room_2 : AABB = AABB(
		Vector3i(room.position.x + x_split, room.position.y, room.position.z), 
		Vector3i(room.size.x - x_split, room.size.y, room.size.z)
		)

	# enqueue both newly created rooms back into the rooms_queue for further processing
	rooms_queue.push_back(room_1)
	rooms_queue.push_back(room_2)

# splits a given room horizontally, creating two new rooms
func split_horizontally(_minHeight : int, rooms_queue : Array[AABB], room : AABB) -> void:
	# generate a random split position along the width of the room
	var y_split : float = randf_range(1, room.size.y)

	# using a split range of (minHeight, room.size.y - minHeight) ensures we always fit 2 
	# rooms but this creates a grid like structure which looks less random
	#var y_split : float = randf_range(minHeight, room.size.y - minHeight)

	# room_1 is defined by the original room's position (bottom-left corner)
	# and extends vertically from the start of the room to the y_split point
	# while the width remains the same as the original room
	var room_1 : AABB = AABB(room.position, Vector3i(room.size.x, y_split, room.size.z))

	# room_2 is defined by the position that starts just after the y_split point
	# and extends to the top of the original room
	# while the width remains the same as the original room
	var room_2 : AABB = AABB(
		Vector3i(room.position.x, room.position.y + y_split, room.position.z), 
		Vector3i(room.size.x, room.size.y - y_split, room.size.z)
		)

	# enqueue both newly created rooms back into the rooms_queue for further processing
	rooms_queue.push_back(room_1)
	rooms_queue.push_back(room_2)

# generates rooms using binary space partitioning (BSP), creates simple rooms from the partitions, 
# and paints the floor tiles for these rooms onto a tilemap
# it also places walls around the generated rooms
func room_first_generation() -> void:
	# clear any existing tiles in the floor and wall tilemaps before generating new ones
	clear_tiles(floor_tilemap_layer)
	clear_tiles(wall_tilemap_layer)
	
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

	# dictionary to hold the floor tiles for the generated rooms
	var floor_tiles : Dictionary = {}

	# create simple rooms by converting the AABB rooms into floor tiles stored in a dictionary
	floor_tiles = create_simple_rooms(rooms_list)

	# array to hold the centers of each room for connecting them with corridors
	var room_centers : Array[Vector2i] = []

	# iterate through each room in the list of rooms
	for room in rooms_list:

		# get the x and y coords of the room's center and round them to integers (for tilemap alignment)
		var room_center_x : int = round(room.get_center().x)
		var room_center_y : int = round(room.get_center().y)

		# add the rounded center position to the room_centers list
		room_centers.append(Vector2i(room_center_x, room_center_y))

	# finds the closest room center and creates corridors between them
	# store all the resulting corridor tiles in a dictionary for later use
	var corridors : Dictionary = connect_rooms(room_centers)

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

# connects rooms by creating corridors between their centers
# the rooms are represented by their center points, and the corridors 
# are stored in a dictionary where each key is a tile position along the corridor
func connect_rooms(room_centers : Array[Vector2i]) -> Dictionary:
	# dictionary to store all the corridor tiles
	var corridors : Dictionary = {}

	# pick a random room center to start with
	var current_room_center : Vector2i = room_centers.pick_random()

	# remove the selected room center from the list to avoid reconnecting it
	room_centers.erase(current_room_center)

	# loop until all room centers have been connected
	while room_centers.size() > 0:
		# find the closest room center to the current room center
		var closest_center : Vector2i = find_closest_room_center(current_room_center, room_centers)

		# remove the closest room center from the list to avoid reconnecting it
		room_centers.erase(closest_center)

		# create a new corridor between the current room center and the closest center
		var new_corridor : Dictionary = create_corridor(current_room_center, closest_center)

		# move to the closest room center to continue the process
		current_room_center = closest_center

		# merge the new corridor tiles into the corridor tiles dictionary
		corridors.merge(new_corridor)

	# return the dictionary containing all the corridor tiles connecting the rooms
	return corridors

# find the closest room center to the current room center from a list of room centers
# calculates the distance between the current room center and each center in the list,
# and returns the one with the smallest distance
func find_closest_room_center(current_room_center : Vector2i, room_centers : Array[Vector2i]) -> Vector2i:
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
func create_corridor(start_position : Vector2i, end_position : Vector2i) -> Dictionary:
	# dictionary to store the positions of corridor tiles
	var corridor : Dictionary = {}

	# set the current position to the starting point of the corridor
	var current_position : Vector2i = start_position

	# add the initial start position to the corridor dictionary
	corridor[current_position] = null

	# move vertically until the current position's y matches the end position's y
	while current_position.y != end_position.y:

		# if the end position is above the current position, move up
		if end_position.y > current_position.y:
			current_position += Vector2i.DOWN;

		# if the end position is below the current position, move down
		elif end_position.y < current_position.y:
			current_position += Vector2i.UP;

		# add the new position to the corridor dictionary
		corridor[current_position] = null

	# move horizontally until the current position's x matches the end position's x
	while current_position.x != end_position.x:

		# if the end position is to the right of the current position, move right
		if end_position.x > current_position.x:
			current_position += Vector2i.RIGHT;

		# if the end position is to the left of the current position, move left
		elif end_position.x < current_position.x:
			current_position += Vector2i.LEFT;

		# add the new position to the corridor dictionary
		corridor[current_position] = null

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
