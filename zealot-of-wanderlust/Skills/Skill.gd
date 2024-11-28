extends Node
class_name Skill

var skill_name : String = "Skill"
var description : String = "Skill Description"
var image_reference : Resource = load("res://ZoW_Logo.png")
var player : Player
enum Rarity {COMMON, UNCOMMON, RARE, ULTRA_RARE, LEGENDARY}
var tier : Rarity = Rarity.COMMON

func add_effect(projectile : Projectile) -> void:
	return
