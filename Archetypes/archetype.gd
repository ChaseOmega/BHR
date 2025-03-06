extends Resource
class_name Archetype

@export var name: String = "Test"
@export var skills: Array[Skill] = []
@export var skillNumber: int
@export var perks: Array[Perk] = []
@export var perkNumber: int
@export var equipmentNumber: int
@export var spriteSet: SpriteFrames

@export var healthCostCurve:Dictionary = {}
@export var attackCostCurve:Dictionary = {}
@export var defenseCostCurve:Dictionary = {}
@export var mobilityCostCurve:Dictionary = {}

func determineStats(healthPoints: int,attackPoints: int, defensePoints: int, mobilityPoints) -> Statline:
	var ReturnStatline = Statline.new()
	ReturnStatline.health = healthCostCurve.get(healthPoints)
	ReturnStatline.attack = attackCostCurve.get(attackPoints)
	ReturnStatline.defense = defenseCostCurve.get(defensePoints)
	ReturnStatline.mobility = mobilityCostCurve.get(mobilityPoints)
	return ReturnStatline
