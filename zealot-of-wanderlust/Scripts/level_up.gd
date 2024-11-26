extends Control
class_name LevelUp

@export var view: View
@export var skill1Btn: Button
@export var skill2Btn: Button
@export var skill3Btn: Button
var skill1 : Skill
var skill2 : Skill
var skill3 : Skill


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	skill1Btn.pressed.connect(view.skill1_chosen)
	skill2Btn.pressed.connect(view.skill2_chosen)
	skill3Btn.pressed.connect(view.skill3_chosen)

func setSkill1Properties(skill : Skill) -> void:
	skill1 = skill
	$CenterContainer/MainContainer/Skill1Container/VBoxContainer/Skill1Name.text = skill.skill_name
	$CenterContainer/MainContainer/Skill1Container/VBoxContainer/Skill1Description.text = skill.description
	$CenterContainer/MainContainer/Skill1Container/Skill1Icon.texture = skill.image_reference

func setSkill2Properties(skill : Skill) -> void:
	skill2 = skill
	$CenterContainer/MainContainer/Skill2Container/VBoxContainer/Skill2Name.text = skill.skill_name
	$CenterContainer/MainContainer/Skill2Container/VBoxContainer/Skill2Description.text = skill.description
	$CenterContainer/MainContainer/Skill2Container/Skill2Icon.texture = skill.image_reference

func setSkill3Properties(skill : Skill) -> void:
	skill3 = skill
	$CenterContainer/MainContainer/Skill3Container/VBoxContainer/Skill3Name.text = skill.skill_name
	$CenterContainer/MainContainer/Skill3Container/VBoxContainer/Skill3Description.text = skill.description
	$CenterContainer/MainContainer/Skill3Container/Skill3Icon.texture = skill.image_reference
