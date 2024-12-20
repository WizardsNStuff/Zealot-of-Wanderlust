extends Node
class_name StateMachine

var current_state: Object

var history = []
var states = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for state in get_children():
		state.fsm = self
		states[state.name] = state
		if current_state:
			remove_child(state)
		else:
			current_state = state
	current_state.enter()
	
func change_to(state_name):
	history.append(current_state.name)
	set_state(state_name)

func back():
	if history.size() > 0:
		set_state(history.pop_back())

func getCurrentState():
	return current_state

func set_state(state_name):
	remove_child(current_state)
	current_state = states[state_name]
	add_child(current_state)
	current_state.enter()

func _exit_tree():
	for state in states.values():
		state.free()
