extends Control
class_name PauseMenu

@export var view: View
@export var unpause_button: Button
@export var exit_button: Button
@onready var skill_container = $ScrollContainer/SkillContainer

# add a skill (label with skill name) to the VBox within the ScrollContainer.
func append_skill_to_container(Skill: String) -> void:
	# make new label and set some of its attributes
	var skill_label = Label.new()
	skill_label.text = Skill
	skill_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	skill_label.font_size = 32
	
	# add the label to the VBox
	skill_container.add_child(skill_label)
