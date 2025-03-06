extends DoubleButton
class_name EffecterVisualizerMini

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

func setColor(inputEffecter: displayable):
	var colorToLoad: Color
	if (inputEffecter == null):
		return
	if (inputEffecter.Type == Enums.EffectType.Attack):
		colorToLoad = Options.colorAttack
	elif (inputEffecter.Type == Enums.EffectType.Defense):
		colorToLoad = Options.colorDefense
	elif (inputEffecter.Type == Enums.EffectType.Trap):
		colorToLoad = Options.colorTrap
	elif (inputEffecter.Type == Enums.EffectType.Movement):
		colorToLoad = Options.colorMovement
	elif (inputEffecter.Type == Enums.EffectType.Special):
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
