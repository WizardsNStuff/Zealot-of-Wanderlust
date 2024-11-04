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

@export var doors : Node

@export var player : Player

var dungeon_created : bool = false
var generated_rooms : Array = []
var exit_location : Vector2i = Vector2i()
var has_key : bool = false

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
	var room_nodes : Array[RoomNode] = []
	dungeon_created = false
	generated_rooms = []
	exit_location = Vector2i()
	has_key = false
	
	var valid_generation : bool = room_first_gen(room_nodes)
	
	if (!valid_generation):
		print("retry")
		start_level()
		return
	else:
		generated_rooms = room_nodes
		for room_node in room_nodes:
			if room_node.is_entrance:
				var floor_positions : Array = room_node.room_tiles.keys()
				var spawn_tile_position : Vector2i = floor_positions.pick_random()
				var spawn_global_position : Vector2 = floor_tilemap_layer.map_to_local(spawn_tile_position)
				player.position = spawn_global_position
				player.visible = true
				dungeon_created = true
				break

func room_first_gen(room_nodes : Array[RoomNode]) -> bool:
	clear_tiles(floor_tilemap_layer)
	clear_tiles(wall_tilemap_layer)
	clear_tiles(staircase_tilemap_layer)
	clear_tiles(door_tilemap_layer)
	clear_doors()

	var rooms_dict_array : Array[RoomNode] = []

	var room_start_position : Vector2i = Vector2i(-proc_gen_data.dungeon_width / 2, -proc_gen_data.dungeon_height / 2)

	var root = bsp(
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

# clears all tiles from the specified tilemap layer
# removes any existing tiles in the tilemap layer, allowing for a fresh start before new tiles are painted
func clear_tiles(tilemap_layer : TileMapLayer) -> void:
	# call the clear method on the tilemap layer to remove all tiles
	tilemap_layer.clear()

func clear_doors() -> void:
	for door in doors.get_children(true):
		door.queue_free()

func bsp(space_to_split : Rect2, min_room_width: int, min_room_height: int) -> RoomNode:
	var root = RoomNode.new(space_to_split)

	split(root, min_room_width, min_room_height)

	return root

func split(node : RoomNode, min_room_width : int, min_room_height : int) -> void:
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

func collect_leaf_nodes_DFS(root : RoomNode, leaves : Array[RoomNode]) -> void:
	if root == null:
		return
	if root.left == null && root.right == null:
		leaves.append(root)
		return
	
	if root.left != null:
		collect_leaf_nodes_DFS(root.left, leaves)
	if root.right != null:
		collect_leaf_nodes_DFS(root.right, leaves)

func create_rooms_using_random_walk(room_nodes : Array[RoomNode]) -> void:
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

func connect_rooms_2(room_nodes : Array[RoomNode]) -> bool:
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

func add_doors_to_corridors(room_nodes : Array[RoomNode]) -> bool:
	var door_number : int = 1
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
			
			var new_door_tilemap_layer = TileMapLayer.new()
			
			new_door_tilemap_layer.tile_set = door_tilemap_layer.tile_set
			new_door_tilemap_layer.name = "Door" + str(door_number)
			new_door_tilemap_layer.set_cell(door_position, door_tilemap_layer.atlas_id, door_tilemap_layer.door_tile_atlas_position)
			
			doors.add_child(new_door_tilemap_layer, true)
			#paint_single_tile(door_tilemap_layer, door_tilemap_layer.atlas_id, door_position, door_tilemap_layer.door_tile_atlas_position)

			door_number += 1
			#for position in outgoing_corridor:
				#if !room_dict["floor_positions"].keys().has(position):
					#door_position = position
					#paint_single_tile(door_tilemap_layer, door_tilemap_layer.atlas_id, door_position, door_tilemap_layer.door_tile_atlas_position)
					#break
	return true

func get_all_tiles(room_nodes : Array[RoomNode]) -> Dictionary:
	var all_tiles = {}
	for room_node in room_nodes:
		if room_node.has_outgoing_corridor():
			for tile in room_node.outgoing_corridor:
				all_tiles[tile] = null
		all_tiles.merge(room_node.room_tiles)
	return all_tiles

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

func generate_exit(exit_room_tiles : Dictionary) -> void:
	var random_floor_position_array : Array = exit_room_tiles.keys()
	randomize()
	random_floor_position_array.shuffle()

	var random_position : Vector2i = random_floor_position_array[0]
	
	exit_location = random_position

	# paint the tile at the chosen random position in the given tilemap layer
	paint_single_tile(staircase_tilemap_layer, staircase_tilemap_layer.atlas_id, random_position, staircase_tilemap_layer.upward_staircase_tile_atlas_position)



func give_player_key():
	has_key = true
	print("gave player 1 key")

func _physics_process(delta: float) -> void:
	if dungeon_created:
		var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		player.velocity = input_direction * player.speed
		var player_collision = player.move_and_slide()
		
		if (player_collision):
			for i in player.get_slide_collision_count():
				var collision = player.get_slide_collision(i)
				var collider = collision.get_collider()
				var collider_name = collider.name
				
				if (collider_name.contains("Door")):
					if (has_key):
						collider.queue_free()
						has_key = false
				if (collider_name.contains("Staircase")):
					start_level()
