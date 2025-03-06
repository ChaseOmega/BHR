extends Resource
class_name Statline

@export var health: int = 0
@export var healthMod: float = 1
@export var attack: int = 0
@export var attackMod: float = 1
@export var attackRange: int = 0
@export var attackRangeMod: float = 1
@export var defense: int = 0
@export var defenseMod: float = 1
@export var mobility: int = 0
@export var mobilityMod: float = 1

func combineStats(otherStatline: Statline) -> Statline:
	var statlineToReturn: Statline = Statline.new()
	statlineToReturn.health = health + otherStatline.health 
	statlineToReturn.healthMod = healthMod * otherStatline.healthMod
	statlineToReturn.attack = attack + otherStatline.attack 
	statlineToReturn.attackMod = attackMod * otherStatline.attackMod
	statlineToReturn.attackRange = attackRange + otherStatline.attackRange
	statlineToReturn.attackRangeMod = attackRangeMod * otherStatline.attackRangeMod
	statlineToReturn.defense = defense + otherStatline.defense
	statlineToReturn.defenseMod = defenseMod * otherStatline.defenseMod
	statlineToReturn.mobility = mobility + otherStatline.mobility
	statlineToReturn.mobilityMod = mobilityMod * otherStatline.mobilityMod
	return statlineToReturn
