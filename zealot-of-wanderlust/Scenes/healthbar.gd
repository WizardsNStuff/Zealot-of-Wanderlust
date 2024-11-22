extends ProgressBar
class_name HealthBar

# node references
@onready var timer = $Timer
@onready var damage_bar = $DamageBar

var health = 0: set = _set_health

func _ready() -> void:
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))

# set health to a new health value after taking damage
func _set_health(new_health):
	var prev_health = health
	health = min(max_value, new_health)
	value = health
	
	# free if player died
	#if health <= 0:
		#queue_free()
	
	if health < prev_health:
		timer.start()
	else:
		damage_bar.value = health

# initialize progress bar values to players initial health
func init_health(_health):
	health = _health
	max_value = health
	value = health
	damage_bar.max_value = health
	damage_bar.value = health

# when the timer timouts make the damage bar the same as health bar
func _on_timer_timeout():
	damage_bar.value = health
