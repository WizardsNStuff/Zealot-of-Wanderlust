extends Node

var fsm: StateMachine

func enter():
	print("Hello from State 2!")
	# Exit state after 2 seconds again
	await get_tree().create_timer(2.0).timeout
	exit()

func exit():
	# Go back to the last state
	fsm.back()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_pressed():
		print("From State2")
