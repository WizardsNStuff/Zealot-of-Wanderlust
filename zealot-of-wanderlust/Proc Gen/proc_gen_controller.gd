extends Node
class_name ProcGenController

@export var proc_gen_data : ProcGenData
@export var floor_tilemap_layer : FloorTileMapLayer

func run_proc_gen() -> void:
	var floor_positions : Dictionary = run_random_walk()
	
	var atlas_id : int = floor_tilemap_layer.atlas_id
	var tile_pos : Vector2i = floor_tilemap_layer.base_floor_tile_atlas_position
	
	clear_tiles(floor_tilemap_layer)
	paint_tiles(floor_positions, floor_tilemap_layer, atlas_id, tile_pos)
	# for visualizing the floor in console
	#for position in floor_positions.keys():
		#print_debug(position)

func run_random_walk() -> Dictionary:
	var current_position : Vector2i = proc_gen_data.start_position
	var floor_positions = {}
	
	for i in range(0, proc_gen_data.room_iterations - 1):
		var path : Dictionary = simple_random_walk(current_position, proc_gen_data.room_walk_length)
		floor_positions.merge(path)
		if (proc_gen_data.room_start_randomly_each_iteration):
			# select random position from floor_positions Dict
			current_position = floor_positions.keys()[randi_range(0, floor_positions.size() - 1)]
	return floor_positions

func simple_random_walk(start_position : Vector2i, walk_length : int) -> Dictionary:
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
