extends Node
class_name Controller

@export var model : Model

var enemies : Array[Enemy]

var game_loaded = false

var showing_arrow = false

@export var view : View

# holds the procedural generation settings, node references, and data
var proc_gen_data : ProcGenData
# reference to the player
var player : Player
var player_cooldown : float
var player_iframes : float
var player_can_be_damaged : bool = true
var leveling_up := false
var enemy_collision_detected = false
var wall_collision_detected = false

func _ready() -> void:
	pass

# class representing a room node in a dungeon
class RoomNode:
	var left : RoomNode = null	# left child room node in binary tree
	var right : RoomNode = null	# right child room node in binary tree
	var room : Rect2 = Rect2()	# rectangle representing the rooms position and size
	var is_leaf : bool = false	# true if this node is a leaf (final room) in binary tree
	var center : Vector2i = Vector2i()	# center point of the room for corridor connection
	var room_tiles : Dictionary = {}	# Dictionary of floor tiles in the room (the keys hold the tile positions)
	var outgoing_corridor : Array = []	# tiles in the outgoing corridor
	var incoming_corridor : Array = []	# tiles in the incoming corridor
	var room_type : int = 0	# type of the room (used for spawning mobs)
	var next_room : RoomNode = null	# reference to the next room in the dungeon
	var prev_room : RoomNode = null	# reference to the previous room in the dungeon
	var is_entrance : bool = false	# true if this room is the starting room for the dungeon
	var is_exit : bool = false	# true if this room is the last room in dungeon and contains a staircase
	var enemies : Array = []

	# constructor initializes the room with a Rect2 representing its posiion and size 
	func _init(room : Rect2):
		self.room = room

	func get_room_type() -> int:
		return self.room_type 

	func add_enemy(enemy) -> void:
		enemies.append(enemy)

	func remove_enemy():
		return enemies.pop_back()

	func get_room_tiles() -> Dictionary:
		return self.room_tiles

	func get_outgoing_corridor() -> Array:
		return outgoing_corridor

	# returns true if the room has an outgoing corridor (used for connecting rooms)
	func has_outgoing_corridor():
		return outgoing_corridor.size() > 0

	# checks if a given position matches the room's center (used for connecting rooms)
	func has_center(c : Vector2i):
		return c == center

	# trims the current room's boundaries by a given amount, 
	# reducing its size and trim all children of the current node in a binary tree
	func trim(trim_amount : int):
		room.position.x += trim_amount
		room.position.y += trim_amount
		room.size.x -= 2 * trim_amount
		room.size.y -= 2 * trim_amount

		if left != null:
			left.trim(trim_amount)
		if right != null:
			right.trim(trim_amount)

func load_tutorial() -> void:
	var tutorial_scene = load("res://Scenes/tutorial.tscn")
	var tutorial_instance = tutorial_scene.instantiate()
	model.tutorial_data = tutorial_instance
	model.add_child(tutorial_instance)
	model.move_child(tutorial_instance, 0)

func start_tutorial() -> void:
	model.in_tutorial = true
	
	view.score_label.visible = true
	view.health_bar.visible = true
	view.player_level_label.visible = true
	view.floor_label.visible = true
	view.floor_label.text = "FLOOR: " + str(proc_gen_data.current_dungeon_floor)
	view.score_label.text = "SCORE: " + str(player.score)
	
	model.tutorial_data.controller = self
	player.position = Vector2i.ZERO
	
	var heart = load("res://Scenes/heart.tscn")
	var heart_instance = heart.instantiate()
	
	heart_instance.controller = self
	heart_instance.position = model.tutorial_data.floor.map_to_local(model.tutorial_data.heart_tile_position)
	
	model.tutorial_data.add_child(heart_instance)
	
	var enemy_1_scene = load("res://Enemy Testing/enemy_1.tscn")
	var enemy_2_scene = load("res://Enemy Testing/minotaur.tscn")
	var enemy_1 = enemy_1_scene.instantiate()
	var enemy_2 = enemy_1_scene.instantiate()
	var enemy_3 = enemy_2_scene.instantiate()
	enemy_1.position = model.tutorial_data.floor.map_to_local(model.tutorial_data.enemy_1_tile_position)
	enemy_2.position = model.tutorial_data.floor.map_to_local(model.tutorial_data.enemy_2_tile_position)
	enemy_3.position = model.tutorial_data.floor.map_to_local(model.tutorial_data.enemy_3_tile_position)
	enemy_1.player = player
	enemy_2.player = player
	enemy_3.player = player
	enemy_1.controller = self
	enemy_2.controller = self
	enemy_3.controller = self
	model.enemy_spawner.add_child(enemy_1)
	model.enemy_spawner.add_child(enemy_2)
	model.enemy_spawner.add_child(enemy_3)
	enemy_1.score = 50
	enemy_2.score = 50
	enemy_1.health = 50
	enemy_2.health = 50
	enemy_1.speed = 0
	enemy_2.speed = 0
	enemy_3.speed = 0
	enemy_3.rush_speed = 0
	enemy_3.health = 50
	enemy_1.main_damage = 0
	enemy_2.main_damage = 0
	enemy_3.main_damage = 0
	enemy_3.rush_damage = 0
	model.spawning_enabled = false
	proc_gen_data.dungeon_created = true

func tutorial_damage_section():
	var original_player_speed = player.speed
	player.speed = 0
	
	var enemy_4_scene = load("res://Enemy Testing/enemy_1.tscn")
	var enemy_4 = enemy_4_scene.instantiate()
	enemy_4.position = model.tutorial_data.floor.map_to_local(model.tutorial_data.enemy_4_tile_position)
	enemy_4.controller = self
	enemy_4.player = player
	var original_player_damage = player.damage
	player.damage = 1
	
	model.enemy_spawner.call_deferred("add_child", enemy_4)
	
	var timer = Timer.new()
	timer.one_shot = true
	timer.timeout.connect(tutorial_damage_section_timeout.bind(timer, original_player_damage, original_player_speed))
	model.tutorial_data.add_child(timer)
	timer.start(2.5)

func tutorial_damage_section_timeout(timer, original_player_damage, original_player_speed) -> void:
	timer.queue_free()
	player.speed = original_player_speed
	player.damage = original_player_damage
	clear_enemy_spawner()

func tutorial_pause_timer_timeout(timer, original_player_speed) -> void:
	timer.queue_free()
	player.speed = original_player_speed

func tutorial_key_timer() -> void:
	var timer = Timer.new()
	timer.one_shot = true
	timer.timeout.connect(key_timer_timeout.bind(timer))
	model.tutorial_data.add_child(timer)
	timer.start(0.1)

func key_timer_timeout(timer) -> void:
	timer.queue_free()
	give_player_key()

func clear_enemy_spawner():
	for child in model.enemy_spawner.get_children():
		child.queue_free()

func tutorial_pause(time):
	var original_player_speed = player.speed
	player.speed = 0
	
	var timer = Timer.new()
	timer.one_shot = true
	timer.timeout.connect(tutorial_pause_timer_timeout.bind(timer, original_player_speed))
	model.tutorial_data.add_child(timer)
	timer.start(time)

func tutorial_complete() -> void:
	view.exit_to_main_menu()

func stop_tutorial() -> void:
	model.call_deferred("remove_child", model.tutorial_data)
	model.tutorial_data.queue_free()
	model.tutorial_data = null
	model.in_tutorial = false
	view.stop_tutorial()

func reset_player() -> void:
	model.remove_child(player)
	model.player.queue_free()
	var player_scene = load("res://Scenes/player.tscn")
	var new_player = player_scene.instantiate()
	model.player = new_player
	player = new_player
	model.add_child(player)
	player.level_up.connect(handle_level_up)
	player.damage_taken.connect(player_take_damage)

# starts the dungeon generation process
func start_level() -> void:
	# reset the procedural generation initalization data
	proc_gen_data.dungeon_created = false
	proc_gen_data.generated_rooms = []
	proc_gen_data.current_room = null
	proc_gen_data.exit_location = Vector2i()
	proc_gen_data.has_key = false
	for child in model.enemy_spawner.get_children(true):
		child.queue_free()
	for child in model.timers.get_children(true):
		child.queue_free()

	# array to hole all the room nodes
	var room_nodes : Array[RoomNode] = []

	# generate rooms and return whether or not the dungeon passes evaluation
	var valid_generation : bool = room_first_gen(room_nodes)

	paint_background()

	# if the generation does not pass evaluation, retry
	if (!valid_generation):
		#print("retry")
		start_level()
		return

	# if generation passes evaluation
	else:

		#for room_node in room_nodes:
			#print(room_node.get_room_tiles().keys(), "\n")
			#print(room_node.get_room_type())

		# update the generated rooms in proc gen data with the newly generated room nodes
		proc_gen_data.generated_rooms = room_nodes

		#print("number of rooms: ", proc_gen_data.generated_rooms.size())

		# check all the room nodes
		for room_node in room_nodes:
			# if the room node is and entrance
			if room_node.is_entrance:

				# get all the floor position from the room
				var floor_positions : Array = room_node.room_tiles.keys()

				# pick a random floor position in the room for the players start position
				var spawn_tile_position : Vector2i = floor_positions.pick_random()

				# convert the floor position to world coordinates
				var spawn_global_position : Vector2 = proc_gen_data.floor_tilemap_layer.map_to_local(spawn_tile_position)

				# move the player to the spawn location
				player.position = spawn_global_position

				# make the player visible
				player.visible = true

				view.score_label.visible = true
				view.health_bar.visible = true
				view.player_level_label.visible = true
				view.floor_label.visible = true
				view.floor_label.text = "FLOOR: " + str(proc_gen_data.current_dungeon_floor)
				view.score_label.text = "SCORE: " + str(player.score)

				# mark the dungeon generation as successful
				proc_gen_data.dungeon_created = true

				proc_gen_data.current_room = room_node

				model.spawn_timer = Timer.new()
				model.timers.add_child(model.spawn_timer)
				model.spawn_timer.stop()
				model.spawn_timer.timeout.connect(spawn_enemy.bind(room_node))
				model.spawning_enabled = true
				model.spawn_timer.start(model.spawn_interval)

				break

# clears all the tiles on the screen
# generates rooms using binary space partitioning
# create each room using a random walk
# connect the rooms with corridors
# add doors to the corridors
# paint all the floor and wall tiles to the screen
# generate and paint 1 staircase in the exit room
func room_first_gen(room_nodes : Array[RoomNode]) -> bool:
	# clear all existing tiles and doors from previous generations
	clear_tiles(proc_gen_data.floor_tilemap_layer)
	clear_tiles(proc_gen_data.wall_tilemap_layer)
	clear_tiles(proc_gen_data.staircase_tilemap_layer)
	clear_tiles(proc_gen_data.door_tilemap_layer)
	clear_tiles(proc_gen_data.object_tilemap_layer)
	clear_doors()
	clear_consumables()

	# array to store room nodes
	var rooms_dict_array : Array[RoomNode] = []

	# define the starting position for the dungeon layout (centered on screen)
	var room_start_position : Vector2i = Vector2i(-proc_gen_data.dungeon_width / 2, -proc_gen_data.dungeon_height / 2)

	# perform binary space partitioning to create a binary tree structure of rooms 
	# each leaf node is a room and each internal node is the space that was split to reach the following nodes
	var root = bsp(
		Rect2(Vector2i(room_start_position.x, room_start_position.y), Vector2i(proc_gen_data.dungeon_width, proc_gen_data.dungeon_height)),
		proc_gen_data.min_room_width,
		proc_gen_data.min_room_height
		)

	# collect all the leaf nodes (individual rooms) from the BSP tree in left to right order
	collect_leaf_nodes_DFS(root, room_nodes)

	# generate each room layout using a random walk
	create_rooms_using_random_walk(room_nodes)

	assign_random_room_types(room_nodes)

	# connect rooms with corridors 
	# if any corridors cross paths 
	# return false to indicate generation failure
	if (!connect_rooms(room_nodes)):
		return false


	var all_room_tiles : Dictionary = {}
	for room_node in room_nodes:
		all_room_tiles.merge(room_node.get_room_tiles())

	var heart_amount = randi_range(3, 6)
	spawn_hearts(heart_amount, all_room_tiles)

	var corridor_exclusive_tiles : Array = []
	# add doors to each corridor
	# if a door cannot be added to a corridor becasue the corridor only exists as part of a room
	# return false to indicate generation failure
	if !add_doors_to_corridors(room_nodes, corridor_exclusive_tiles, all_room_tiles):
		return false

	#print("Corridor tiles ", corridor_exclusive_tiles)
	
	paint_all_corridor_exclusive_tiles(corridor_exclusive_tiles)

	var all_corridor_exclusive_tiles : Array = []

	for sub_arr in corridor_exclusive_tiles:
		for tile in sub_arr:
			all_corridor_exclusive_tiles.append(tile)

	paint_room_specific_tiles(room_nodes, all_corridor_exclusive_tiles)

	# paint walls around the corridors
	create_corridor_walls(room_nodes, proc_gen_data.wall_tilemap_layer, proc_gen_data.wall_tilemap_layer.atlas_id, proc_gen_data.wall_tilemap_layer.cobblestone_wall_tile_atlas_position, all_corridor_exclusive_tiles)
	# paint walls around all the floor tiles
	#create_walls(get_all_tiles(room_nodes), proc_gen_data.wall_tilemap_layer, proc_gen_data.wall_tilemap_layer.atlas_id, proc_gen_data.wall_tilemap_layer.brick_wall_tile_atlas_position)

	# check every room node
	for room_node in room_nodes:

		# if the room node is an exit
		if room_node.is_exit:

			# generate a stiarcase randomly in the exit room and paint the tile
			generate_exit(room_node.room_tiles)

			break

	# return true to indicate successful generation of the dungeon
	return true

# clears all tiles from the specified tilemap layer
# removes any existing tiles in the tilemap layer, allowing for a fresh start before new tiles are painted
func clear_tiles(tilemap_layer : TileMapLayer) -> void:
	# call the clear method on the tilemap layer to remove all tiles
	tilemap_layer.clear()

# removes all existing door tilemap layers from the dungeon
func clear_doors() -> void:
	# loop through each child node (tilemap layer) of doors_root_node
	for door in proc_gen_data.doors_root_node.get_children():

		# delete each door (tilemap layer) to reset the layout 
		door.queue_free()

# removes all existing consumables from the dungeon
func clear_consumables() -> void:
	# loop through each child node of consumables_node
	for object in model.consumables_node.get_children():
		# delete each object 
		object.queue_free()

# creates a binary space partitioning (BSP) tree by recursively splitting the given space into smaller rooms
# returns the root RoomNode of the generated BSP tree
func bsp(space_to_split : Rect2, min_room_width: int, min_room_height: int) -> RoomNode:
	# create the root node of the BSP tree with the initial space to split
	var root = RoomNode.new(space_to_split)

	# recursively split the root node to create the room subdivisions based on minimum room size constraints
	split(root, min_room_width, min_room_height)

	# return the root node, which contains the entire BSP structure as a tree of RoomNodes
	return root

# recursively splits a RoomNode into smaller rooms using binary space partitioning (BSP) based on minimum room size
# this function updates the node with left and right child nodes representing the split rooms
func split(node : RoomNode, min_room_width : int, min_room_height : int) -> void:
	# get position and size of the room within the current node
	var px : int = node.room.position.x
	var py : int = node.room.position.y
	var sx : int = node.room.size.x
	var sy : int = node.room.size.y

	# variables to store split line, new room rectangles, and new room nodes
	var split : float
	var room_1_rect : Rect2 
	var room_2_rect : Rect2
	var room_1 : RoomNode
	var room_2 : RoomNode

	# check if the current room is too small to split further based on minimum room sizes
	if (sx < min_room_width) && (sy < min_room_height):
		# Mark as a leaf node (no further splits)
		node.is_leaf = true
		return

	# randomly decide whether to split horizontally or vertically
	var random_split : float = randf() >= 0.5

	# perform horizontal split
	if random_split && sy >= (min_room_height * 2):

		# decide where to split the room along the y-axis based on random or even split settings
		if proc_gen_data.bsp_random_splits == true:

			# randomly split within the room height
			split = randf_range(1, sy)

		else:
			# slit within minimum size constraints
			split = randi_range(min_room_height, sy - min_room_height)

		# create the rectangles for the two new sub-rooms after the horizontal split
		room_1_rect = Rect2(node.room.position, Vector2i(sx, split))
		room_2_rect = Rect2(Vector2i(px, py + split), Vector2i(sx, sy - split))

	# perform vertical split
	elif sx >= (min_room_width * 2):

		# decide where to split the room along the y-axis based on random or even split settings
		if proc_gen_data.bsp_random_splits == true:

			# randomly split within the room width
			split = randf_range(1, sx)

		else:
			# slit within minimum size constraints
			split = randi_range(min_room_width, sx - min_room_width)

		# create the rectangles for the two new sub-rooms after the vertical split
		room_1_rect = Rect2(node.room.position, Vector2i(split, sy))
		room_2_rect = Rect2(Vector2i(px + split, py), Vector2i(sx - split, sy))

	# if no valid split was possible, mark the node as a leaf and stop splitting
	else:
		node.is_leaf = true
		return

	# update the current nodes left and rigth nodes with new nodes for the split rooms
	if (node.left == null):
		node.left = RoomNode.new(room_1_rect)
	if (node.right == null):
		node.right = RoomNode.new(room_2_rect)

	# recursively split the left and right child nodes
	split(node.left, min_room_width, min_room_height)
	split(node.right, min_room_width, min_room_height)

# collects all leaf nodes from the BSP tree using Depth-First Search (DFS) traversal
# leaf nodes (rooms) are added to the 'leaves' array
func collect_leaf_nodes_DFS(root : RoomNode, leaves : Array[RoomNode]) -> void:
	# if the current root node is null, there is nothing to process, so exit the function
	if root == null:
		return

	# check if the current node is a leaf (no left or right children)
	if root.left == null && root.right == null:
		# add the leaf nodes to the array
		leaves.append(root)
		# return becasue traversal of leaf node is not needed
		return

	# if the left child exists, recursively collect leaf nodes from the left subtree
	if root.left != null:
		collect_leaf_nodes_DFS(root.left, leaves)

	# if the right child exists, recursively collect leaf nodes from the right subtree
	if root.right != null:
		collect_leaf_nodes_DFS(root.right, leaves)

# generates floor tiles for each room using a random walk algorithm to create irregular room shapes
# the function ensures that each generated floor tile is within the bounds of the room
func create_rooms_using_random_walk(room_nodes : Array[RoomNode]) -> void:
	# itterate through each room node to generate floor tiles.
	for room_node in room_nodes:

		# get the room of the current room node
		var room : Rect2 = room_node.room

		# get the approximate center of the current room, rounding to integer coordinates
		var room_center : Vector2i = Vector2i(round(room.get_center().x), round(room.get_center().y))

		# update the room node's center attribute with the calculated center position
		room_node.center = room_center

		# run the random walk algorithm, starting from the room center, to generate floor positions
		var room_floor_positions : Dictionary = run_random_walk(room_center)

		# dictionary to hold valid room floor tiles within the bounds of the room
		var valid_floor_positions : Dictionary = {}

		# check each position generated by the random walk to ensure it lies within the room's edges
		for position in room_floor_positions:

			# calculate the x,y position of the edges of the room 
			var left_edge : int = room.position.x
			var right_edge : int = room.position.x + room.size.x
			var top_edge : int = room.position.y
			var bottom_edge : int = room.position.y + room.size.y

			# ensure the position is within the valid bounds of the room
			if (position.x >= left_edge && position.x <= right_edge&& position.y >= top_edge && position.y <= bottom_edge):

				# if the position is valid, add it to the valid floor positions dictionary
				valid_floor_positions[position] = null

		# update the room node's room_tiles attribute with the valid floor positions dictionary
		room_node.room_tiles = valid_floor_positions

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

# connects rooms by creating corridors between their center points. 
# this function ensures all rooms are reachable from a starting room
# returns true if successful, false if there is a tile conflict (i.e. duplicate corridor tiles)
func connect_rooms(room_nodes : Array[RoomNode]) -> bool:
	# dictionary to store all tiles occupied by corridors, used to detect conflicts
	var all_corridor_tiles = {}
	
	# dictionary to store each corridor tile
	var corridors : Dictionary = {}

	# array to store the center positions of each room
	var room_centers: Array[Vector2i] = []

	# collect all the room centers from the array of room nodes
	for room_node in room_nodes:
		room_centers.append(room_node.center)

	# start by selecting the first room center as the starting point
	var current_room_center : Vector2i = room_centers[0]

	# mark the starting room as the entrance to dungeon
	for room_node in room_nodes:
		if room_node.has_center(current_room_center):
			room_node.is_entrance = true
			break

	# remove the selected room center from the list to avoid reconnecting it
	room_centers.erase(current_room_center)

	# loop until all room centers have been connected with corridors
	while room_centers.size() > 0:
		# find the closest room center to the current room center
		var closest_center : Vector2i = find_closest_room_center(current_room_center, room_centers)

		# if only one room center remains, mark it corresponding room node as the exit
		if room_centers.size() == 1:
			for room_node in room_nodes:
				if room_node.has_center(closest_center):
					room_node.is_exit = true
					break

		# remove the closest room center from the list to avoid reconnecting it
		room_centers.erase(closest_center)

		# create a new corridor between the current room center and the closest center
		var new_corridor : Array = create_corridor(current_room_center, closest_center)

		# Check each tile in the new corridor for conflicts
		# add it to all_corridor_tiles if unique
		# if not unique tile conflict found, return false
		for tile in new_corridor:
			# check if the tile already exists in all_corridor_tiles, indicating a conflict
			if all_corridor_tiles.keys().has(tile):
				return false

			else:

				# add the tile to all_corridor_tiles if it's unique
				# avoid adding the starting and ending tiles, as these are room centers and will overlap between corridors
				if tile != current_room_center && tile != closest_center:
					all_corridor_tiles[tile] = null

		# loop through all the room nodes
		for room_node in room_nodes:
			# check if the room_node matches the current room center
			if room_node.has_center(current_room_center):
				# assign the newly created corridor to this room's outgoing_corridor
				room_node.outgoing_corridor = new_corridor

				# find the room node corresponding to the closest room center 
				# and set it as the next room to the current room node
				for room_node_i in room_nodes:
					if room_node_i.has_center(closest_center):
						room_node.next_room = room_node_i

			# check if the room_node matches the closest room center
			elif room_node.has_center(closest_center):
				# duplicate and reverse the corridor to assign it as the incoming corridor for the closest room
				var reversed_corridor : Array = new_corridor.duplicate(true)
				reversed_corridor.reverse()
				room_node.incoming_corridor = reversed_corridor

				# find the room node matching the current room center 
				# and set it as the previous room for the closest room
				for room_node_i in room_nodes:
					if room_node_i.has_center(current_room_center):
						room_node.prev_room = room_node_i

		# move to the closest room center to continue the remaining rooms
		current_room_center = closest_center

	# return true is all rooms are sucessfully connected with no overlapping corridors
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

# add doors to each corridor in the array of room nodes
# if a door cannot be placed on a corridor becasue the
# the corridor overlaps with a room's floor tiles
# return false to indicate generation failure
func add_doors_to_corridors(room_nodes : Array[RoomNode], all_corridor_exclusive_tiles : Array, all_room_tiles : Dictionary) -> bool:
	# initalize a counter to assign unique names to each dorr layer
	var door_number : int = 1

	# loop through each room node in the array
	for room_node in room_nodes:

		# check if the current room has an outgoing corridor
		if room_node.has_outgoing_corridor():

			# get the outgoing corridor array from the room
			var outgoing_corridor : Array = room_node.outgoing_corridor
			# get the current room's floor tiles
			var current_floor : Dictionary = room_node.room_tiles

			# vector to hold the position of the door on the tilemap layer
			var door_position  : Vector2i

			# dictionary for the next room's floor tiles
			var next_floor : Dictionary = {}

			# get the center  position of the next room
			var next_center = room_node.next_room.center

			# array to store tiles that are exclusive to the corridor (not in current or next room)
			var corridor_exclusive_tiles : Array = []

			# find the floor tiles of the next room node by matching its center
			for room_node_i in room_nodes:
				if room_node_i.has_center(next_center):
					next_floor = room_node_i.room_tiles

			# loop through each tile in the outgoing corridor to identify corridor-exclusive tiles
			for tile in outgoing_corridor:
				# add tiles to corridor_exclusive_tiles if they don't overlap with either room's floor tiles
				if !current_floor.keys().has(tile) && !next_floor.keys().has(tile):
					corridor_exclusive_tiles.append(tile)

			# if no exclusive corridor tiles are found, return false
			if corridor_exclusive_tiles.size() == 0:
				return false

			all_corridor_exclusive_tiles.append(corridor_exclusive_tiles)

			# set the door position to the midpoint of corridor_exclusive_tiles
			door_position = corridor_exclusive_tiles[corridor_exclusive_tiles.size() / 2]

			if all_room_tiles.keys().has(door_position):
				return false

			var surrounding_door_wall_positions : Array = []
			for direction in proc_gen_data.direction_list:
				if corridor_exclusive_tiles.has(door_position + direction) == false:
					surrounding_door_wall_positions.append(door_position + direction)
			
			if surrounding_door_wall_positions.size() <= 2:
				for tile in surrounding_door_wall_positions:
					paint_single_tile(proc_gen_data.wall_tilemap_layer, proc_gen_data.wall_tilemap_layer.atlas_id, tile, proc_gen_data.wall_tilemap_layer.cobblestone_wall_tile_atlas_position)

			# create a new TileMapLayer instance for the door
			var new_door_tilemap_layer = TileMapLayer.new()

			# give the instance the same tile set as the door tilemap layer in proc gen data
			new_door_tilemap_layer.tile_set = proc_gen_data.door_tilemap_layer.tile_set

			# give the door tilemap layer a unique name starting with "Door" so it can be identified
			new_door_tilemap_layer.name = "Door" + str(door_number)

			# set a door tile at the chosen door position in the new layer
			new_door_tilemap_layer.set_cell(door_position, proc_gen_data.door_tilemap_layer.atlas_id, proc_gen_data.door_tilemap_layer.door_tile_atlas_position)

			# add the door layer to the root node for doors in the scene
			proc_gen_data.doors_root_node.add_child(new_door_tilemap_layer, true)

			# increment door_number to uniquely name the next door layer
			door_number += 1

	# return true if all doors where successfully placed on corridors
	return true

# collects all floor and corridor tiles from an array of room nodes
# returns a dictionary containing each tile position as keys, ensuring no duplicates
func get_all_tiles(room_nodes : Array[RoomNode]) -> Dictionary:
	# empty dictionary to store all tiles
	var all_tiles = {}

	# loop through each room node in the array
	for room_node in room_nodes:

		# if the current room has an outgoing corridor, add all its tiles to all_tiles
		if room_node.has_outgoing_corridor():
			for tile in room_node.outgoing_corridor:
				all_tiles[tile] = null

		# merge the current room's floor tiles into all_tiles
		all_tiles.merge(room_node.room_tiles)

	# return the dictionary of all the tiles of all the rooms
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

func create_room_walls(floor_positions : Dictionary, tilemap_layer : TileMapLayer, tilemap_layer_atlas_id : int , tile_atlas_position : Vector2i, corridor_exclusive_tiles : Array) -> void:
	# find wall edge positions based on the floor positions and the defined direction list
	var wall_positions : Dictionary = find_wall_edges_not_on_corrior(floor_positions, proc_gen_data.direction_list, corridor_exclusive_tiles)

	# iterate through each wall position and paint a wall tile at that position
	for position in wall_positions:
		# paint a single wall tile at the current position using the specified tilemap layer and atlas information
		paint_single_tile(tilemap_layer, tilemap_layer_atlas_id, position, tile_atlas_position)

func create_corridor_walls(room_nodes : Array[RoomNode], tilemap_layer : TileMapLayer, tilemap_layer_atlas_id : int , tile_atlas_position : Vector2i, corridor_exclusive_tiles : Array) -> void:
	var all_room_tiles : Dictionary = {}
	for room_node in room_nodes:
		all_room_tiles.merge(room_node.get_room_tiles())

	# find wall edge positions based on the floor positions and the defined direction list
	var wall_positions : Dictionary = find_corridor_wall_edges(all_room_tiles, proc_gen_data.direction_list, corridor_exclusive_tiles)

	# iterate through each wall position and paint a wall tile at that position
	for position in wall_positions:
		# paint a single wall tile at the current position using the specified tilemap layer and atlas information
		paint_single_tile(tilemap_layer, tilemap_layer_atlas_id, position, tile_atlas_position)

func find_corridor_wall_edges(floor_positions : Dictionary, direction_list : Array, corridor_exclusive_tiles : Array) -> Dictionary:
	# dictionary to store wall positions
	var wall_positions : Dictionary = {}

	# iterate through each position in the corridor positions array
	for position in corridor_exclusive_tiles:
		# check each direction in the direction list
		for direction in direction_list:
			# calculate the neighbor position based on the current position and direction
			var neighbor_position = position + direction

			# if there is no floor tile at the neighbor position
			if (corridor_exclusive_tiles.has(neighbor_position) == false) && (floor_positions.keys().has(neighbor_position) == false):
				# add the neighbor position to the wall positions
				wall_positions[neighbor_position] = null

	# return the dictionary containing all wall positions
	return wall_positions

func find_wall_edges_not_on_corrior(floor_positions : Dictionary, direction_list : Array, corridor_exclusive_tiles : Array) -> Dictionary:
	# dictionary to store wall positions
	var wall_positions : Dictionary = {}

	# iterate through each position in the floor positions dictionary
	for position in floor_positions:
		# check each direction in the direction list
		for direction in direction_list:
			# calculate the neighbor position based on the current position and direction
			var neighbor_position = position + direction

			# if there is no floor tile at the neighbor position
			if (floor_positions.keys().has(neighbor_position) == false) && (corridor_exclusive_tiles.has(neighbor_position) == false):
				# add the neighbor position to the wall positions
				wall_positions[neighbor_position] = null

	# return the dictionary containing all wall positions
	return wall_positions

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

# randomly selects a tile position from the provided exit room tiles and designates it as the exit
# it then updates the tilemap to display an exit staircase at that position
func generate_exit(exit_room_tiles : Dictionary) -> void:
	# convert the keys (tile positions) of the exit_room_tiles dictionary into an array for random selection
	var random_floor_position_array : Array = exit_room_tiles.keys()

	# seed the random number generator to ensure different results each run
	randomize()

	# shuffle the array to randomize the order of tile positions
	random_floor_position_array.shuffle()

	# select the first tile in the shuffled array as the random position for the exit
	var random_position : Vector2i = random_floor_position_array[0]

	# store the chosen exit location in proc_gen_data for easy access in other parts of the code
	proc_gen_data.exit_location = random_position

	# paint the tile at the chosen random position in the given tilemap layer
	paint_single_tile(proc_gen_data.staircase_tilemap_layer, proc_gen_data.staircase_tilemap_layer.atlas_id, random_position, proc_gen_data.staircase_tilemap_layer.upward_staircase_tile_atlas_position)

# give the player a key, allowing them to unlock doors
func give_player_key():
	# set the key flag to true in the proc gen data
	proc_gen_data.has_key = true
	view.play_key_animation()
	player.key_sfx.play()
	if !model.in_tutorial:
		show_arrow()

func show_arrow() -> void:
	var door_position = find_door()
	proc_gen_data.next_door_position = door_position
	showing_arrow = true

func find_door() -> Vector2i:
	var corridor_with_door = proc_gen_data.current_room.get_outgoing_corridor()
	if corridor_with_door.size() != 0:
		for tilemaplayer in proc_gen_data.doors_root_node.get_children():
			var door_position = tilemaplayer.get_used_cells()[0]
			if (corridor_with_door.has(door_position)):
				return tilemaplayer.map_to_local(door_position)
	else:
		var door_position = proc_gen_data.staircase_tilemap_layer.get_used_cells()[0]
		return proc_gen_data.staircase_tilemap_layer.map_to_local(door_position)
	return Vector2i.ZERO

func player_has_key() -> bool:
	return proc_gen_data.has_key || proc_gen_data.permanent_key

# handle player collision with a door
func handle_door_collision(collider : Object) -> void:
	# check if the player has a key
	if player_has_key():
		# unlock the door and remove it from the scene
		collider.queue_free()
		
		player.door_unlock_sfx.play()
		
		# set key flag to false after use
		proc_gen_data.has_key = false

		view.stop_key_animation()

		if model.in_tutorial:
			pass
		# move to next room
		elif (proc_gen_data.current_room.next_room != null):
			proc_gen_data.current_room = proc_gen_data.current_room.next_room
			
			# rebind the spawn timer to the new room
			model.spawn_timer.stop()
			model.spawn_timer.disconnect("timeout", spawn_enemy)
			model.spawn_timer.timeout.connect(spawn_enemy.bind(proc_gen_data.current_room))
			
			spawn_pause(2)

func spawn_pause(amount) -> void:
	var timer = Timer.new()
	timer.one_shot = true
	timer.timeout.connect(spawn_pause_timer_timeout.bind(timer))
	model.timers.add_child(timer)
	timer.start(amount)

func spawn_pause_timer_timeout(timer) -> void:
	model.timers.remove_child(timer)
	timer.queue_free()
	start_enemy_spawning()

func start_enemy_spawning() -> void:
	model.spawning_enabled = true
	model.spawn_timer.start()

# handle player collision with a stair
func handle_stair_collision(collider : Object) -> void:
	# check if the player has a key
	if player_has_key():

		# set key flag to false after use
		proc_gen_data.has_key = false

		view.stop_key_animation()

		proc_gen_data.current_dungeon_floor += 1

		start_level()

func enemy_spawning_finished() -> void:
	model.spawn_timer.stop()
	model.spawning_enabled = false

func unpause_game() -> void:
	get_tree().paused = false

func handle_input(delta: float) -> void:
	# get the input direction for movement
	var input_direction = Vector2.ZERO
	var attack_direction = Vector2.ZERO
	
	input_direction.x = Input.get_action_strength("ui_right")- Input.get_action_strength("ui_left")
	input_direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	input_direction = input_direction.normalized()
	
	if Input.is_action_just_pressed("ui_cancel") && !leveling_up:
		# Flip the pause state
		get_tree().paused = !get_tree().paused
		view.game_paused()
		if get_tree().paused:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	elif !get_tree().paused:
		view.pause_menu_node.hide()
		# set the player's velocity
		if (input_direction != Vector2.ZERO):
			player.velocity = player.velocity.move_toward(input_direction * player.speed, delta * player.acceleration)
		else:
			player.velocity = player.velocity.move_toward(input_direction * player.speed, delta * 1000)
		# attack
		attack_direction.x = Input.get_action_strength("attack_right")- Input.get_action_strength("attack_left")
		attack_direction.y = Input.get_action_strength("attack_down") - Input.get_action_strength("attack_up")
		attack_direction = attack_direction.normalized()
		if attack_direction != Vector2.ZERO && !player.is_attacking:
			# Player can't attack while moving
			player.velocity = Vector2.ZERO
			attack(attack_direction)
		else:
			attack_direction = Vector2.ZERO
			
		handle_animations(input_direction, attack_direction)

func attack(attack_direction: Vector2) -> void:
	# start the attack
	player_cooldown = Time.get_unix_time_from_system() + player.damage_cooldown
	player.is_attacking = true
	
	# spawn projectile
	var projectile_scene := load("res://Player Combat/projectile.tscn")
	var projectile : Projectile = projectile_scene.instantiate()
	projectile.rotation = attack_direction.angle()
	projectile.damage = player.damage
	projectile.projectile_life = Time.get_unix_time_from_system() + player.projectile_life_span
	projectile.velocity = attack_direction * player.projectile_speed
	projectile.global_position = player.global_position
	
	# add Skill Changes
	if !player.skill_list.is_empty():
		for skill in player.skill_list:
			(skill as Skill).add_effect(projectile)
	
	# fire
	model.add_child(projectile)

func handle_animations(walk_dir, attack_dir) -> void:
	var state_machine = player.animations["parameters/playback"]
	
	if attack_dir != Vector2.ZERO && player.is_attacking:
		player.animations.set("parameters/Idle/blend_position", attack_dir)
		player.animations.set("parameters/Attack/blend_position", attack_dir)
		if !player.shooting_sfx.playing:
			player.shooting_sfx.play()
		state_machine.travel("Idle")
		state_machine.travel("Attack")
	elif walk_dir != Vector2.ZERO:
		player.animations.set("parameters/Idle/blend_position", walk_dir)
		player.animations.set("parameters/Walk/blend_position", walk_dir)
		# Walking SFX
		#if !player.walking_sfx.playing:
			#player.walking_sfx.play()
		state_machine.travel("Walk")
	else:
		state_machine.travel("Idle")

func get_random_tile_in_room(room_node : RoomNode) -> Vector2i:
	randomize()
	return room_node.room_tiles.keys().pick_random()

func player_take_damage(damage_amount : float) -> void:
	player.health -= damage_amount
	
	player.player_damaged_sfx.play()
	player_can_be_damaged = false
	player_iframes = Time.get_unix_time_from_system() + player.iframes
	# flashes the player sprite on damage
	player.sprite.modulate = Color.SKY_BLUE
	player.damage_flash_timer.start()

	if player.health <= 0:
		player.health = 0
		game_over()
	view.health_bar.health = player.health

func game_over() -> void:
	proc_gen_data.dungeon_created = false
	view.game_over()

func spawn_enemy(room_node : RoomNode) -> void:
	if room_node.enemies.size() > 0:
		var enemy = room_node.remove_enemy().instantiate()
		var random_tile : Vector2i = get_random_tile_in_room(room_node)
		enemy.position = proc_gen_data.floor_tilemap_layer.map_to_local(random_tile)
		enemy.player = player
		enemy.controller = self
		model.enemy_spawner.add_child(enemy)
	else:
		enemy_spawning_finished()

#func spawn_enemies_in_room(room_node : RoomNode):
	#var random_tile : Vector2i = get_random_tile_in_room(room_node)
	#
	#var enemy = model.minotaur_enemy.instantiate()
	#enemy.position = proc_gen_data.floor_tilemap_layer.map_to_local(random_tile)
	#enemy.player = player
	#enemy.controller = self
	#model.enemy_spawner.add_child(enemy)

func quit_game() -> void:
	get_tree().quit()

func play_again() -> void:
	player._ready()
	view.health_bar.init_health(player.health)
	view.score_label.text = "Health: " + str(player.score)
	view.player_level_label.text = "LVL: " + str(player.level)
	view.health_bar.set_exp(player.experience)
	view.health_bar.set_max_hp_value(player.level_up_threshold)
	proc_gen_data.current_dungeon_floor = 1
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func update_score(score_amount : float) -> void:
	player.score += score_amount
	player.experience += score_amount
	view.score_label.text = "Score: " + str(player.score)
	view.health_bar.set_exp(player.experience)
	view.health_bar.set_max_hp_value(player.level_up_threshold)
	view.player_level_label.text = "LVL: " + str(player.level)

func get_random_room_type() -> int:
	var room_types = proc_gen_data.ROOM_TYPE.keys()
	randomize()
	return randi_range(0, room_types.size() - 1)

func assign_random_room_types(room_nodes : Array[RoomNode]) -> void:
	for room_node in room_nodes:
		room_node.room_type = get_random_room_type()
		give_room_enemies(room_node)

func give_room_enemies(room_node : RoomNode) -> void:
	var room_type_name : String = get_room_type_name(room_node.room_type)
	
	var skeleton_count : int
	var minotaur_count : int
	var slime_count : int
	
	match room_type_name:
		"SKELETONS":
			skeleton_count = floor(pow((proc_gen_data.current_dungeon_floor + 2), 1.5))
			for i in range(skeleton_count):
				room_node.add_enemy(model.skeleton_enemy)
		"SKELETONS_AND_MINOTAURS":
			skeleton_count = floor(pow((proc_gen_data.current_dungeon_floor + 2), 1.2))
			minotaur_count = floor((proc_gen_data.current_dungeon_floor + 2) * 0.6)

			for i in range(skeleton_count):
				room_node.add_enemy(model.skeleton_enemy)

			for i in range(minotaur_count):
				room_node.add_enemy(model.minotaur_enemy)

		"SKELETONS_AND_SLIMES":
			skeleton_count = floor((proc_gen_data.current_dungeon_floor + 3) * 0.5)
			slime_count = floor((proc_gen_data.current_dungeon_floor + 1) * 3)

			for i in range(slime_count):
				room_node.add_enemy(model.slime_enemy)

			for i in range(skeleton_count):
				room_node.add_enemy(model.skeleton_enemy)

		"MINOTAURS":
			minotaur_count = proc_gen_data.current_dungeon_floor * 2
			for i in range(minotaur_count):
				room_node.add_enemy(model.minotaur_enemy)


func get_room_type_name(value : int) -> String:
	var enum_keys = proc_gen_data.ROOM_TYPE.keys()

	for key in enum_keys:
		if proc_gen_data.ROOM_TYPE[key] == value:
			return key

	return "SKELETONS"

func paint_room_specific_tiles(room_nodes : Array[RoomNode], corridor_exclusive_tiles : Array) -> void:
	# the a	tlas ID for the floor tilemap layer
	var floor_atlas_id : int = proc_gen_data.floor_tilemap_layer.atlas_id
	# get the atlas ID for the wall tilemap layer
	var wall_atlas_id : int = proc_gen_data.wall_tilemap_layer.atlas_id
	# get the atlas ID for the object tilemap layer
	var object_atlas_id : int = proc_gen_data.object_tilemap_layer.atlas_id
	
	for room_node in room_nodes:
		# get all floor tile positions for the generated rooms and corridors 
		var room_tiles = room_node.get_room_tiles()
		
		var room_type = get_room_type_name(room_node.get_room_type())

		# the position of the floor tile in the atlas
		var floor_tile_pos : Vector2i
		# the position of the wall tile in the atlas
		var wall_tile_pos : Vector2i

		var objects : Dictionary = {}

		match room_type:
			"SKELETONS":
				floor_tile_pos = proc_gen_data.floor_tilemap_layer.green_floor_tile_atlas_position
				wall_tile_pos = proc_gen_data.wall_tilemap_layer.clay_wall_tile_atlas_position
				objects[proc_gen_data.object_tilemap_layer.white_tall_grass_object_tile_atlas_position] = 5
				objects[proc_gen_data.object_tilemap_layer.bone_pile_1_object_tile_atlas_position] = 5
				objects[proc_gen_data.object_tilemap_layer.small_white_sapling_object_tile_atlas_position] = 5
			"SKELETONS_AND_MINOTAURS":
				floor_tile_pos = proc_gen_data.floor_tilemap_layer.light_green_floor_tile_atlas_position
				wall_tile_pos = proc_gen_data.wall_tilemap_layer.ice_wall_tile_atlas_position
				objects[proc_gen_data.object_tilemap_layer.red_tall_grass_object_tile_atlas_position] = 5
				objects[proc_gen_data.object_tilemap_layer.small_pink_flowers_object_tile_atlas_position] = 5
				objects[proc_gen_data.object_tilemap_layer.leaf_pile_1_object_tile_atlas_position] = 5
			"SKELETONS_AND_SLIMES":
				floor_tile_pos = proc_gen_data.floor_tilemap_layer.light_brown_floor_tile_atlas_position
				wall_tile_pos = proc_gen_data.wall_tilemap_layer.sponge_wall_tile_atlas_position
				objects[proc_gen_data.object_tilemap_layer.red_bush_object_tile_atlas_position] = 5
				objects[proc_gen_data.object_tilemap_layer.tulips_object_tile_atlas_position] = 5
				objects[proc_gen_data.object_tilemap_layer.corn_object_tile_atlas_position] = 5
			"MINOTAURS":
				floor_tile_pos = proc_gen_data.floor_tilemap_layer.red_floor_tile_atlas_position
				wall_tile_pos = proc_gen_data.wall_tilemap_layer.brick_wall_tile_atlas_position
				objects[proc_gen_data.object_tilemap_layer.small_red_mushrooms_object_tile_atlas_position] = 5
				objects[proc_gen_data.object_tilemap_layer.blood_spill_1_object_tile_atlas_position] = 5
				objects[proc_gen_data.object_tilemap_layer.small_orange_grass_object_tile_atlas_position] = 5

		# paint the floor tiles
		paint_tiles(room_tiles, proc_gen_data.floor_tilemap_layer, floor_atlas_id, floor_tile_pos)
		# paint the wall tiles
		#create_walls(room_tiles, proc_gen_data.wall_tilemap_layer, wall_atlas_id, wall_tile_pos)
		if (proc_gen_data.paint_walls):
			create_room_walls(room_tiles, proc_gen_data.wall_tilemap_layer, wall_atlas_id, wall_tile_pos, corridor_exclusive_tiles)

		paint_collision_free_objects_randomly(objects, room_node, proc_gen_data.object_tilemap_layer, object_atlas_id)

func paint_collision_free_objects_randomly(objects : Dictionary, room_node : RoomNode, tilemap_layer : TileMapLayer, atlas_id : int) -> void:
	for tile_atlas_pos in objects.keys():
		var object_amount = objects[tile_atlas_pos]
	
		for i in range(object_amount):
			var random_tile : Vector2i = get_random_tile_in_room(room_node)
			paint_single_tile(tilemap_layer, atlas_id, random_tile, tile_atlas_pos)

func paint_all_corridor_exclusive_tiles(corridor_exclusive_tiles : Array) -> void:
	
	# the atlas ID for the floor tilemap layer
	var floor_atlas_id : int = proc_gen_data.floor_tilemap_layer.atlas_id
	# get the atlas ID for the wall tilemap layer
	var wall_atlas_id : int = proc_gen_data.wall_tilemap_layer.atlas_id

	# the position of the floor tile in the atlas
	var floor_tile_pos : Vector2i = proc_gen_data.floor_tilemap_layer.corridor_floor_tile_atlas_position
	# the position of the wall tile in the atlas
	var wall_tile_pos : Vector2i
	
	for sub_arr in corridor_exclusive_tiles:
		for tile in sub_arr:
			paint_single_tile(proc_gen_data.floor_tilemap_layer, floor_atlas_id, tile, floor_tile_pos)

func paint_background() -> void:
	var tilemap_layer = proc_gen_data.background_tilemap_layer
	var atlas_id = proc_gen_data.background_tilemap_layer.atlas_id
	var normal_tile = proc_gen_data.background_tilemap_layer.background_tile_atlas_position
	var grass_tile = proc_gen_data.background_tilemap_layer.grass_background_tile_atlas_position
	
	var w = proc_gen_data.dungeon_width + (proc_gen_data.background_padding * 2)
	var h = proc_gen_data.dungeon_height + (proc_gen_data.background_padding * 2)
	
	for i in range(-w / 2, w / 2):
		for j in range(-h / 2, h / 2):
			var tile_pos = Vector2i(i,j)
			if (randi() % 100 < 10):
				paint_single_tile(tilemap_layer, atlas_id, tile_pos, grass_tile)
			else:
				paint_single_tile(tilemap_layer, atlas_id, tile_pos, normal_tile)

func get_living_enemy_count() -> int:
	return model.enemy_spawner.get_child_count(false)

# gets called in the enemy script when the enemy health reaches 0 the enemy is 
# queue_freed directly after this check hence the check for 1 livig enemt and not 0
func check_key_status() -> bool:
	if get_living_enemy_count() == 1 && model.spawning_enabled == false:
		return true
	return false

func spawn_hearts(amount : int, tiles : Dictionary) -> void:
	for i in range(amount):
		var heart = model.heart.instantiate()
		heart.controller = self
		
		randomize()
		var random_tile_pos : Vector2i = tiles.keys().pick_random()

		# convert the floor position to world coordinates
		var spawn_global_position : Vector2 = proc_gen_data.floor_tilemap_layer.map_to_local(random_tile_pos)

		# move the heart to the spawn location
		heart.position = spawn_global_position

		model.consumables_node.add_child(heart)

func handle_level_up() -> void:
	# pause the game and allow the user to select a skill
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	leveling_up = true
	var rng = RandomNumberGenerator.new()
	var skill1 := model.skills[rng.rand_weighted(model.skill_weights)] as Skill
	var skill2 := model.skills[rng.rand_weighted(model.skill_weights)] as Skill
	var skill3 := model.skills[rng.rand_weighted(model.skill_weights)] as Skill
	view.init_skills(skill1, skill2, skill3)
	view.level_up()

func add_skill(skill : Skill) -> void:
	var temp_skill : Skill = skill.duplicate()
	temp_skill._ready()
	temp_skill.player = player
	player.skill_list.append(temp_skill)
	view.add_skill_to_pause_screen(temp_skill)
	
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	leveling_up = false
	get_tree().paused = false

func add_player_health(amount) -> void:
	player.health += amount
	
	if player.health > player.original_health:
		player.health = player.original_health
	view.health_bar.health = player.health

func collect_heart(heart) -> void:
	if player.health < player.original_health:
		add_player_health(25)
		player.heart_collect_sfx.play()
		heart.queue_free()

func load_game() -> void:
	var proc_gen_scene = load("res://Scenes/proc_gen_data.tscn")
	var proc_gen_instance = proc_gen_scene.instantiate()
	model.add_child(proc_gen_instance)
	model.move_child(proc_gen_instance, 0)
	
	model.proc_gen_data = proc_gen_instance
	
	var player_scene = load("res://Scenes/player.tscn")
	var player_instance = player_scene.instantiate()
	model.add_child(player_instance)
	model.move_child(player_instance, 1)
	
	model.player = player_instance
	
	proc_gen_data = model.proc_gen_data
	player = model.player
	view.health_bar.init_health(player.health)
	view.health_bar.set_exp(player.experience)
	view.health_bar.set_max_hp_value(player.level_up_threshold)
	player.level_up.connect(handle_level_up)
	player.damage_taken.connect(player_take_damage)
	
	game_loaded = true

func unload_game() -> void:
	var proc_gen_instance = model.proc_gen_data
	model.remove_child(proc_gen_instance)
	model.proc_gen_data = null
	proc_gen_instance.queue_free()
	
	var player_instance = model.player
	model.remove_child(player_instance)
	model.player = null
	player_instance.queue_free()
	
	var enemy_spawner_node = model.enemy_spawner
	for enemy in enemy_spawner_node.get_children():
		enemy_spawner_node.remove_child(enemy)
		enemy.queue_free()
	
	var timer_node = model.timers
	for timer in timer_node.get_children():
		timer_node.remove_child(timer)
		timer.queue_free()

	var consumables_node = model.consumables_node
	for item in consumables_node.get_children():
		consumables_node.remove_child(item)
		item.queue_free()

	game_loaded = false

func player_enemy_hit_sfx(enemy_dead) -> void:
	if enemy_dead:
		player.enemy_death_sfx.play()
	else:
		player.enemy_hit_sfx.play()

func update_arrow() -> void:
	var player_pos = player.global_position
	player_pos = Vector2(player_pos.x, player_pos.y * -1)
	var door_pos = proc_gen_data.next_door_position
	if door_pos == null:
		view.toggle_arrow(false)
		showing_arrow = false
		return
	door_pos = Vector2(door_pos.x, door_pos.y * -1)
	
	var direction_to_door = player_pos.direction_to(door_pos)
	
	var angle_to_door = rad_to_deg(direction_to_door.angle()) * -1 + 90
	
	view.arrow.rotation = deg_to_rad(angle_to_door)

# handle player movement and player interactions in each frame
func _physics_process(delta: float) -> void:
	# check if the dungeon has been created before allowing interactions
	if game_loaded && proc_gen_data.dungeon_created:
		handle_input(delta)
		
		# don't process anything if paused
		if get_tree().paused: return
		
		if Time.get_unix_time_from_system() >= player_cooldown:
			player.is_attacking = false

		if showing_arrow:
			view.toggle_arrow(true)
			update_arrow()

		# move the player and retrieve if any collisions occured
		var player_collision = player.move_and_slide()

		# if a collision occurred during movement, process each collision
		if (player_collision):

			# loop thorugh all the collisions with the player
			for i in player.get_slide_collision_count():

				# get the collision at index i
				var collision = player.get_slide_collision(i)

				# get the collider associated with the collision
				var collider = collision.get_collider()

				# get the name of the collider
				var collider_name = collider.name

				if (collider is Enemy):
					enemy_collision_detected = true
					if (player_can_be_damaged):
						player_take_damage(collider.main_damage)
					# check if iFrames are over
					if (Time.get_unix_time_from_system() >= player_iframes):
						player_can_be_damaged = true

				# check if the collision is with a door
				if (collider_name.contains("Door")):
					view.toggle_arrow(false)
					showing_arrow = false
					handle_door_collision(collider)

				# check if collision is with a staircase
				if (collider_name.contains("Staircase")):
					view.toggle_arrow(false)
					showing_arrow = false
					handle_stair_collision(collider)
				
				if (collider_name.contains("Wall")):
					wall_collision_detected = true
			
			# Player collision layer is 0, mask layers are 1, 2
			# Walls are physics layer 0 (mask 1 for the player)
			# Enemies are physics layer 2, masks 1, 2, 3
			if enemy_collision_detected and wall_collision_detected:
				# temporarily disable certain physics/mask layers of the player
				player.set_collision_layer_value(3, false)
				player.set_collision_mask_value(2, false)
				
				# re-enable those layers after 0.5 secs to let the player get unstuck
				await get_tree().create_timer(0.5).timeout
				player.set_collision_mask_value(2, true)
				player.set_collision_layer_value(3, true)
				enemy_collision_detected = false
				wall_collision_detected = false
