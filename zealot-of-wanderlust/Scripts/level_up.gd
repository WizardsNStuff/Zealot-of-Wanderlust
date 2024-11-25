extends Control
class_name LevelUp

@export var view: View
@export var skill1Btn: Button
@export var skill2Btn: Button
@export var skill3Btn: Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	skill1Btn.pressed.connect(view.skill1_chosen)
	skill1Btn.pressed.connect(view.skill2_chosen)
	skill2Btn.pressed.connect(view.skill3_chosen)

func setSkill1Properties(name: String, description: String, icon: Resource) -> void:
	$CenterContainer/MainContainer/Skill1Container/VBoxContainer/Skill1Name.text = name
	$CenterContainer/MainContainer/Skill1Container/VBoxContainer/Skill1Description.text = description
	$CenterContainer/MainContainer/Skill1Container/Skill1Icon.texture = icon

func setSkill2Properties(name: String, description: String, icon: Resource) -> void:
	$CenterContainer/MainContainer/Skill2Container/VBoxContainer/Skill2Name.text = name
	$CenterContainer/MainContainer/Skill2Container/VBoxContainer/Skill2Description.text = description
	$CenterContainer/MainContainer/Skill2Container/Skill2Icon.texture = icon

func setSkill3Properties(name: String, description: String, icon: Resource) -> void:
	$CenterContainer/MainContainer/Skill3Container/VBoxContainer/Skill3Name.text = name
	$CenterContainer/MainContainer/Skill3Container/VBoxContainer/Skill3Description.text = description
	$CenterContainer/MainContainer/Skill3Container/Skill3Icon.texture = icon
