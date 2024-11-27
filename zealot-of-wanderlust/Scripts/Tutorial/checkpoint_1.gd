extends Area2D

@export var tutorial : Node

func _ready() -> void:
	self.body_entered.connect(self.checkpoint_entered)

func checkpoint_entered(body):
	tutorial.checkpoint_entered(self.name)
	self.queue_free()
