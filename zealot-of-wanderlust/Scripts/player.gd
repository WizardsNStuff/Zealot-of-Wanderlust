extends GameCharacter
class_name Player

##### Player Stats #####
# Leviathan
var charged_damage : int
var charged_damage_cooldown : float
# Counter
var parry_cooldown : float
# Enhancement
var active_buffs := {
	# Damage applicable to any instance of damage
	"all_damage_buff": 0,
	# Blitz magic buff
	"main_damage_buff": 0,
	"main_cooldown_buff": 0,
	# Leviathan Magic buff
	"charged_damage_buff": 0,
	"charged_cooldown_buff": 0,
	# Counter Magic buff
	"parry_cooldown_buff": 0,
	# Basic Stat Buffs
	"health_buff": 0,
	"defense_buff": 0
}
########################
