extends Control
class_name equipmentInterface

@export var player: Match_Player
@export var unit: Server_Unit
@export var equipmentHolder: HBoxContainer
@export var effecterVisualizerBase: PackedScene
@export var activationButton: Button
@export var selectedEquipment: Equipment

func setup(inputPlayer: Match_Player):
	player = inputPlayer
	unit = inputPlayer.playerUnit
	refreshValues()
	SignalManager.RefreshUI.connect(refreshValues)
	activationButton.button_down.connect(selectedCardSpecialFunction)
	pass

func refreshValues():
	for child in equipmentHolder.get_children():
		child.queue_free()
	for equipment in unit.equipment:
		var equipmentAdded:EffecterVisualizerMini = effecterVisualizerBase.instantiate()
		equipmentAdded.effecter = equipment
		equipmentAdded.button_down.connect(selectEquipment.bind(equipment))
		equipmentHolder.add_child(equipmentAdded)

func selectEquipment(equipmentToSelect:Equipment):
	print(equipmentToSelect.name)
	selectedEquipment = equipmentToSelect
	activationButton.show()
	if selectedEquipment.effectCondition(unit):
		activationButton.disabled = false
	else:
		activationButton.disabled = true
	pass

func selectedCardSpecialFunction():
	MatchServer.effectActivationClientPrep(selectedEquipment,unit)
