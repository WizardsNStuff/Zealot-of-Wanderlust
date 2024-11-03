extends Node2D
class_name RoomDrawTesting

var room_list
var canDraw

func set_room_list(list):
	room_list = list
	canDraw = true
	queue_redraw()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _draw() -> void:
	if (canDraw):
		for room in room_list:
			draw_rect(room, Color(randf(), randf(), randf()))
