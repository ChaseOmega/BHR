extends Control
class_name EffecterVisualizer

@export var coloredRegions:Array[ColorRect]
@export var art: TextureRect
@export var title: Label
@export var description: Label
@export var flavor: Label
@export var value: Label
@export var effecter:displayable:
	set(value):
		effecter = value
		setColor(effecter)
		setText(effecter)

func _ready():
	SignalManager.requestDisplayInfo.connect(_onDisplayInfo)

func _onDisplayInfo(effecterToDisplay: displayable):
	effecter = effecterToDisplay
	showDisplay()
	pass

func setColor(inputEffecter: displayable):
	var colorToLoad: Color
	if (inputEffecter.Type == inputEffecter.EffectType.Attack):
		colorToLoad = Options.colorAttack
	elif (inputEffecter.Type == inputEffecter.EffectType.Defense):
		colorToLoad = Options.colorDefense
	elif (inputEffecter.Type == inputEffecter.EffectType.Trap):
		colorToLoad = Options.colorTrap
	elif (inputEffecter.Type == inputEffecter.EffectType.Movement):
		colorToLoad = Options.colorMovement
	elif (inputEffecter.Type == inputEffecter.EffectType.Special):
		colorToLoad = Options.colorSpecial
	for Rect in coloredRegions:
		Rect.color.r = colorToLoad.r
		Rect.color.g = colorToLoad.g
		Rect.color.b = colorToLoad.b
		
func setText(inputEffecter: displayable):
	if (description != null):
		description.text = inputEffecter.description
	if (flavor != null):
		flavor.text = inputEffecter.flavorText
	if (title != null):
		title.text = inputEffecter.name
	if (value != null && inputEffecter is Card):
		value.text = str(inputEffecter.value)
	else:
		value.get_parent_control().hide()

func hideDisplay():
	hide()

func showDisplay():
	show()
