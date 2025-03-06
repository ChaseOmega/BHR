extends Resource
class_name displayable
@export var Type: Enums.EffectType  = Enums.EffectType.Attack

@export var name: String = ""
@export_multiline var description: String = ""
@export_multiline var flavorText: String = ""
@export_multiline var instanceText: String = ""
@export var art: Texture


func loadDictionary(input:Dictionary):
	name = input.name
	description = input.description
	flavorText = input.flavorText
	art = input.art
