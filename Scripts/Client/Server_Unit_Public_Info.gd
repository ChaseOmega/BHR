extends Resource
class_name Server_Unit_Public_Info

@export var displayStats: Statline
@export var displaySkills: Array[int]
@export var displayPerks: Array[int]
@export var displayEquipment: Array[int]
@export var displayHealth: int
@export var displayMaxHealth: int
@export var displayAttack: int = 0
@export var displayDefense: int
@export var displayMobility: int

func loadDictionary(input:Dictionary):
	displayStats = input.displayStats
	displaySkills = input.displaySkills
	displayPerks = input.displayPerks
	displayEquipment = input.displayEquipment
	displayHealth = input.displayHealth
	displayMaxHealth = input.displayMaxHealth
	displayAttack = input.displayAttack
	displayDefense = input.displayDefense
	displayMobility = input.displayMobility
