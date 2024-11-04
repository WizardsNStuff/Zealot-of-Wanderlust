extends Node2D
#class_name RoomDrawTesting
#
#var room_list
#var canDraw
#
#func set_room_list(list):
	#room_list = list
	#canDraw = true
	#queue_redraw()
#
#func _draw() -> void:
	#if (canDraw):
		#for room in room_list:
			#draw_rect(room, Color(randf(), randf(), randf()))
