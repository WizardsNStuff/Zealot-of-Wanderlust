extends Node

var fsm: StateMachine

func enter():
	print("Hello from State 1!")
	# Exit 2 seconds later
	await  get_tree().create_timer(2.0).timeout
	exit("State2") # switch to next state

func exit(next_state):
	fsm.change_to(next_state)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_pressed():
		print("From State1")
