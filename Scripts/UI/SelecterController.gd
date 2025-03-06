extends Control
class_name SelecterController

@export var maxDuplicates: int = -1
@export var minSelected: int = -1
@export var maxSelected: int = -1
@export var Type: Manifest.testEnum = Manifest.testEnum.Card
@export_group("Info")
@export var optionsSelected: Array[displayable] = []
@export var options: Array[displayable] = []
@export_group("Sensitive")
@export var selectedDisplay: GridContainer
@export var optionsDisplay: GridContainer
@export var visualizerBase: PackedScene

func _ready():
	match Type:
		Manifest.testEnum.Card:
			options.append_array(Manifest.cards)
		Manifest.testEnum.Skill:
			options.append_array(Manifest.skills)
		Manifest.testEnum.Perk:
			options.append_array(Manifest.perks)
		Manifest.testEnum.Equipment:
			options.append_array(Manifest.equipment)
	loadOptionButtons()

func clear():
	optionsSelected.clear()
	refreshDisplay()
	
func addOptionToSubmission(inputEffecter:displayable):
	if (optionsSelected.size() >= maxSelected && maxSelected > -1):
		print("You have too much stuff selected")
	elif(optionsSelected.count(inputEffecter) >= maxDuplicates && maxDuplicates > -1):
		print ("Sorry chief can't have that many dups")
	else:
		optionsSelected.append(inputEffecter)
		refreshDisplay()

func removeOptionFromSubmission(inputEffecter:displayable):
	optionsSelected.pop_at(optionsSelected.find(inputEffecter))
	refreshDisplay()
	pass


func loadOptions(optionsToLoad:Array):
	options.clear()
	options.append_array(optionsToLoad)
	loadOptionButtons()
	refreshDisplay()
	pass

func loadOptionButtons():
	for child in optionsDisplay.get_children():
		child.queue_free()
	for effecter in options:
		var optionAdded:EffecterVisualizerMini = visualizerBase.instantiate()
		optionAdded.effecter = effecter
		optionAdded.primaryPressed.connect(addOptionToSubmission.bind(effecter))
		optionAdded.secondaryPressed.connect(MatchServer.displayInfo.bind(effecter))
		optionsDisplay.add_child(optionAdded)

func refreshDisplay():
	for child in selectedDisplay.get_children():
		child.queue_free()
	for effecter in optionsSelected:
		var optionAdded:EffecterVisualizerMini = visualizerBase.instantiate()
		optionAdded.effecter = effecter
		selectedDisplay.add_child(optionAdded)
		optionAdded.primaryPressed.connect(removeOptionFromSubmission.bind(effecter))
		optionAdded.secondaryPressed.connect(MatchServer.displayInfo.bind(effecter))
