extends Node
class_name Skill

var skill_name : String = "Skill"
var description : String = "Skill Description"
var image_reference : Resource = load("res://icon.svg")
var player : Player

func add_effect(projectile : Projectile) -> void:
	return
