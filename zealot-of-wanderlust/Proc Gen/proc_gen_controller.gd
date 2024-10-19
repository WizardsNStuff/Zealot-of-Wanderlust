extends Node
class_name ProcGenController

@export var proc_gen_data : ProcGenData
@export var floor_tilemap_layer : FloorTileMapLayer
@export var wall_tilemap_layer : WallTileMapLayer

func run_proc_gen() -> void:
	var floor_positions : Dictionary = run_random_walk()
	
	var floor_atlas_id : int = floor_tilemap_layer.atlas_id
	var floor_tile_pos : Vector2i = floor_tilemap_layer.base_floor_tile_atlas_position
	
	var wall_atlas_id : int = wall_tilemap_layer.atlas_id
	var wall_tile_pos : Vector2i = wall_tilemap_layer.base_wall_tile_atlas_position
	
	clear_tiles(floor_tilemap_layer)
	clear_tiles(wall_tilemap_layer)
	
	paint_tiles(floor_positions, floor_tilemap_layer, floor_atlas_id, floor_tile_pos)
	create_walls(floor_positions, wall_tilemap_layer, wall_atlas_id, wall_tile_pos)
	# for visualizing the floor in console
	#for position in floor_positions.keys():
		#print_debug(position)

func run_random_walk() -> Dictionary:
	var current_position : Vector2i = proc_gen_data.start_position
	var floor_positions = {}
	
	for i in range(0, proc_gen_data.room_iterations - 1):
		var path : Dictionary = simple_random_walk_room(current_position, proc_gen_data.room_walk_length)
		floor_positions.merge(path)
		if (proc_gen_data.room_start_randomly_each_iteration):
			# select random position from floor_positions Dict
			current_position = floor_positions.keys()[randi_range(0, floor_positions.size() - 1)]
	return floor_positions

func simple_random_walk_room(start_position : Vector2i, walk_length : int) -> Dictionary:
	# walkLength : how many steps agent will do before returning
	var path : Dictionary = {}
	
	path[start_position] = null
	
	var previous_position : Vector2i = start_position
	
	for i in range(0, walk_length):
		var new_position : Vector2i = previous_position + get_random_direction()
		path[new_position] = null;
		previous_position = new_position
	
	return path

func get_random_direction() -> Vector2i:
	return proc_gen_data.direction_list.pick_random()

func paint_tiles(tile_positions : Dictionary, tilemap_layer : TileMapLayer, tilemap_layer_atlas_id : int , tile_atlas_position : Vector2i) -> void:
	for tile_pos in tile_positions.keys():
		paint_single_tile(tilemap_layer, tilemap_layer_atlas_id, tile_pos, tile_atlas_position)

func paint_single_tile(tilemap_layer : TileMapLayer, tilemap_layer_atlas_id : int , paint_position : Vector2i, tile_atlas_position : Vector2i) -> void:
	tilemap_layer.set_cell(paint_position, tilemap_layer_atlas_id, tile_atlas_position)

func clear_tiles(tilemap_layer : TileMapLayer) -> void:
	tilemap_layer.clear()

func create_walls(floor_positions : Dictionary, tilemap_layer : TileMapLayer, tilemap_layer_atlas_id : int , tile_atlas_position : Vector2i) -> void:
	var wall_positions : Dictionary = find_wall_edges(floor_positions, proc_gen_data.direction_list)
	for position in wall_positions:
		paint_single_tile(tilemap_layer, tilemap_layer_atlas_id, position, tile_atlas_position)

# finds the positions where walls should be placed based on a floors empty neighboring tiles 
func find_wall_edges(floor_positions : Dictionary, direction_list : Array) -> Dictionary:
	var wall_positions : Dictionary = {}
	for position in floor_positions:
		for direction in direction_list:
			var neighbor_position = position + direction
			# if there is no neighbor for the current tile add wall to list of walls
			if (floor_positions.keys().has(neighbor_position) == false):
				wall_positions[neighbor_position] = null
	return wall_positions

func random_walk_corridor(start_position : Vector2i, corridor_length : int) -> Array:
	var corridor : Array = []
	var direction = get_random_direction()
	var current_position = start_position
	corridor.append(current_position)

	for i in range(0, corridor_length):
		current_position += direction
		corridor.append(current_position)

	return corridor

# generates corridors and adds their positions to the set of floor positions
func create_corridors(floor_positions : Dictionary) -> void:
	var current_position = proc_gen_data.start_position
	
	# loop through the corridor amount to generate multiple corridors
	for i in range(0, proc_gen_data.corridor_amount):
		# generate a corridor using a random walk algorithm, starting from current_position
		var corridor = random_walk_corridor(current_position, proc_gen_data.corridor_walk_length)
		# update current_position to the end of the newly created corridor
		current_position = corridor[corridor.size() - 1]
		
		# add all positions of the corridor to the set of floor positions
		for position in corridor:
			# add the position to the dictionary
			floor_positions[position] = null

func corridor_first_generation() -> void:
	var floor_positions : Dictionary = {}
	
	create_corridors(floor_positions);
	
	var floor_atlas_id : int = floor_tilemap_layer.atlas_id
	var corridor_tile_pos : Vector2i = floor_tilemap_layer.base_corridor_floor_tile_atlas_position
	
	var wall_atlas_id : int = wall_tilemap_layer.atlas_id
	var corridor_wall_tile_pos : Vector2i = wall_tilemap_layer.base_corridor_wall_tile_atlas_position
	
	paint_tiles(floor_positions, floor_tilemap_layer, floor_atlas_id, corridor_tile_pos)
	
	create_walls(floor_positions, wall_tilemap_layer, wall_atlas_id, corridor_wall_tile_pos)
