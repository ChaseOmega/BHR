extends Effecter
class_name Skill

var typeID:int = 0 
#unlike with cards this is entirely for visualization purposes and does not change the properties of skills


@export var statModifier: Statline = Statline.new()

func _init():
	pass

func loadDictionary(input:Dictionary):
	super(input)
	typeID = input.typeID
