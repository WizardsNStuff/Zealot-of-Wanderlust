extends Node
class_name ProcGenController

@export var proc_gen_algorithm : ProcGenAlogrithm

func run_proc_gen() -> void:
	var floor_positions : Dictionary = run_random_walk()
	# for visualizing the floor in console
	for position in floor_positions.keys():
		print_debug(position)

func run_random_walk() -> Dictionary:
	var current_position : Vector2i = proc_gen_algorithm.start_position
	var floor_positions = {}
	
	for i in range(0, proc_gen_algorithm.iterations - 1):
		var path : Dictionary = simple_random_walk(current_position, proc_gen_algorithm.walk_length)
		floor_positions.merge(path)
		if (proc_gen_algorithm.start_randomly_each_iteration):
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
	return proc_gen_algorithm.direction_list[randi_range(0, proc_gen_algorithm.direction_list.size() - 1)]
