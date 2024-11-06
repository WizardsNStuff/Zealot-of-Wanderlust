extends GameCharacter

var speed = 50
var player_chase = false
var player = null

func _ready() -> void:
	### Declaring attributes from GameCharacterScript ###
	health = 100
	defense = 20
	main_damage = 15
	main_damage_cooldown = 1.5
	
	### Connecting signals ###
	var detection_area = $"Detection Area"
	detection_area.connect("body_entered", Callable(self, "_on_detection_area_body_entered"))
	detection_area.connect("body_exited", Callable(self, "_on_detection_area_body_exited"))

func _physics_process(delta: float) -> void:
	if player_chase:
		position += (player.position - position) / speed


func _on_detection_area_body_entered(body: Node2D) -> void:
	player = body
	player_chase = true


func _on_detection_area_body_exited(body: Node2D) -> void:
	player = null
	player_chase = false
