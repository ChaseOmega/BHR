extends Resource
class_name playerInfo

@export var userName: String
@export var characterSheet: CharacterSheet

func _init(inputName: String = "Placeholder", inputSheet: CharacterSheet = CharacterSheet.new()):
	userName = inputName
	characterSheet = inputSheet
