extends Control
class_name skillInterface

@export var player: Match_Player
@export var unit: Server_Unit
@export var skillHolder: HBoxContainer
@export var effecterVisualizerBase: PackedScene
@export var activationButton: Button
@export var selectedSkill: Skill

func setup(inputPlayer: Match_Player):
	player = inputPlayer
	unit = inputPlayer.playerUnit
	refreshValues()
	SignalManager.RefreshUI.connect(refreshValues)
	activationButton.button_down.connect(selectedCardSpecialFunction)
	pass

func refreshValues():
	for child in skillHolder.get_children():
		child.queue_free()
	for skill in unit.skills:
		var skillAdded:EffecterVisualizerMini = effecterVisualizerBase.instantiate()
		skillAdded.effecter = skill
		skillAdded.button_down.connect(selectSkill.bind(skill))
		skillHolder.add_child(skillAdded)

func selectSkill(skillToSelect:Skill):
	print(skillToSelect.name)
	selectedSkill = skillToSelect
	activationButton.show()
	if selectedSkill.effectCondition(unit):
		activationButton.disabled = false
	else:
		activationButton.disabled = true
	pass

func selectedCardSpecialFunction():
	MatchServer.effectActivationClientPrep(selectedSkill,unit)
