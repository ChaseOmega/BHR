extends Control

@export var archetypeSelect: OptionButton
var characterSheetResult: CharacterSheet = CharacterSheet.new()
@export var nameInput: LineEdit
@export var levelInput: SpinBox

@export var cardInput: SelecterController
@export var equipmentInput: SelecterController
@export var skillsInput: SelecterController
@export var perksInput: SelecterController

@export var cardsToSubmit: Array[int] = []
@export var effecterVisualizerBase: PackedScene


@export var healthSelection: OptionButton
@export var attackSelection: OptionButton
@export var defenseSelection: OptionButton
@export var mobilitySelection: OptionButton
@export var spLabel: Label
@export var spWarningMessage: Label
@export var maxSP: int

var submitted:bool = false

func submit():
	if (!submitted):
		characterSheetResult.name = nameInput.text
		characterSheetResult.level = levelInput.value
		characterSheetResult.archetype = archetypeSelect.selected
		submitStats()
		submitPerks()
		submitSkills()
		submitEquipment()
		MatchServer._addCardArrayToDeckRequest.rpc(cardsToSubmit)
		Lobby.registerPlayer.rpc(inst_to_dict(characterSheetResult))
	pass
	
func _ready():
	archetypeSelect.item_selected.connect(loadArchetypeDetails.unbind(1))
	_readyArchetypes()
	_readyStats()
	_readyPerks()
	_readySkills()
	_readyEquipment()
	archetypeSelect.select(-1)
	pass # Replace with function body.

func _readyArchetypes():
	for type in Manifest.archetypes:
		archetypeSelect.add_item(type.name,Manifest.archetypes.find(type))

func loadArchetypeDetails():
	loadStats()
	loadCards()
	loadPerks()
	loadSkills()
	loadEquipment()
	
#region Cards
func _readyCards():
	pass
func loadCards():
	cardInput.loadOptions(Manifest.cards)
	pass
func submitCards():
	for x in cardInput.optionsSelected:
		cardsToSubmit.append(Manifest.cards.find(x))
	pass
#endregion

#region Stats
func _readyStats():
	healthSelection.item_selected.connect(StatCheck.unbind(1))
	attackSelection.item_selected.connect(StatCheck.unbind(1))
	defenseSelection.item_selected.connect(StatCheck.unbind(1))
	mobilitySelection.item_selected.connect(StatCheck.unbind(1))
	
func loadStats():
	spWarningMessage.hide()
	healthSelection.clear()
	attackSelection.clear()
	defenseSelection.clear()
	mobilitySelection.clear()
	spLabel.text = str(0) + "/" + str(maxSP)
	var archetypeToLoad:Archetype = Manifest.archetypes[archetypeSelect.get_selected_id()]
	for stat in archetypeToLoad.healthCostCurve:
		healthSelection.add_item("Health: " + str(archetypeToLoad.healthCostCurve[stat]) + " \nThis Costs: " + str(stat) + " SP",stat)
	for stat in archetypeToLoad.attackCostCurve:
		attackSelection.add_item("Attack: " + str(archetypeToLoad.attackCostCurve[stat]) + " \nThis Costs: " + str(stat) + " SP",stat)
	for stat in archetypeToLoad.defenseCostCurve:
		defenseSelection.add_item("Defense: " + str(archetypeToLoad.defenseCostCurve[stat]) + " \nThis Costs: " + str(stat) + " SP",stat)
	for stat in archetypeToLoad.mobilityCostCurve:
		mobilitySelection.add_item("Mobility: " + str(archetypeToLoad.mobilityCostCurve[stat]) + " \nThis Costs: " + str(stat) + " SP",stat)

func StatCheck() -> bool:
	var totalSPUsed = 0
	totalSPUsed += healthSelection.get_selected_id()
	totalSPUsed += attackSelection.get_selected_id()
	totalSPUsed += defenseSelection.get_selected_id()
	totalSPUsed += mobilitySelection.get_selected_id()
	spLabel.text = str(totalSPUsed) + "/" + str(maxSP)
	if (totalSPUsed > maxSP):
		spWarningMessage.show()
		return false
	else:
		spWarningMessage.hide()
		return false

func submitStats():
	characterSheetResult.statPointsHealth = healthSelection.get_selected_id()
	characterSheetResult.statPointsAttack = attackSelection.get_selected_id()
	characterSheetResult.statPointsDefense = defenseSelection.get_selected_id()
	characterSheetResult.statPointsMobility = mobilitySelection.get_selected_id()
	pass
#endregion

#region Perks
func _readyPerks():
	pass
func loadPerks():
	perksInput.loadOptions(Manifest.perks)
	pass
func submitPerks():
	for x in perksInput.optionsSelected:
		characterSheetResult.perks.append(Manifest.perks.find(x))
	pass
#endregion

#region Skills
func _readySkills():
	pass

func loadSkills():
	skillsInput.loadOptions(Manifest.skills)
	pass
	
func submitSkills():
	for x in skillsInput.optionsSelected:
		characterSheetResult.skills.append(Manifest.skills.find(x))
	pass
#endregion
	
#region Equipment
func _readyEquipment():
	pass

func loadEquipment():
	equipmentInput.loadOptions(Manifest.equipment)
	pass
	
func submitEquipment():
	for x in equipmentInput.optionsSelected:
		characterSheetResult.equipment.append(Manifest.equipment.find(x))
	pass
#endregion
