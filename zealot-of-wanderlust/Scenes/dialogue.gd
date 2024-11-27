extends Node2D

@export var next_char_timer : Timer
@export var next_message_timer : Timer
@export var label : Label

var messages = [
	"First Message",
	"Second MEssage For you"
]

var typing_speed = 0.05
var read_time = 2

var current_message = 0
var display = ""
var current_char = 0

func _ready() -> void:
	next_char_timer.timeout.connect(_on_next_char_timer_timeout)
	next_message_timer.timeout.connect(_on_next_message_timer_timeout)

func start_dialogue() -> void:
	current_message = 0
	display = ""
	current_char = 0
	
	next_char_timer.set_wait_time(typing_speed)
	next_char_timer.start()

func stop_dialogue() -> void:
	#get_parent().remove_child(self)
	self.queue_free()

func _on_next_char_timer_timeout() -> void:
	if (current_char < len(messages[current_message])):
		var next_char = messages[current_message][current_char]
		display += next_char
		
		label.text = display
		current_char += 1
	else:
		next_char_timer.stop()
		next_message_timer.one_shot = true
		next_message_timer.set_wait_time(read_time)
		next_message_timer.start()

func _on_next_message_timer_timeout() -> void:
	if (current_message == len(messages) - 1):
		#stop_dialogue()
		next_char_timer.stop()
		next_message_timer.stop()
	else:
		current_message += 1
		display = ""
		current_char = 0
		next_char_timer.start()
