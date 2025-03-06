extends Resource
class_name CharacterSheet

@export var name: String
@export var level: int
@export var archetype: int
@export var statPointsHealth: int = 0
@export var statPointsAttack: int = 0
@export var statPointsDefense: int = 0
@export var statPointsMobility: int = 0
@export var currentHealth: int = 0
var stats: Statline = Statline.new();
@export var skills: Array[int]
@export var perks: Array[int]
@export var equipment: Array[int]
@export var deck: Array[int]

# Make sure that every parameter has a default value.
# Otherwise, there will be problems with creating and editing
# your resource via the inspector.
func _init(p_Name = "Test_Dummy", p_level = 0, p_spriteSet = 0,p_archetype = 0 , p_skills:Array[int] = [], p_perks:Array[int] = [], p_equipment:Array[int] = [], p_deck:Array[int] = [], p_statPointsHealth = 0, p_statPointsDefense = 0, p_statPointsAttack = 0, p_statPointsMobility = 0):
	name = p_Name
	level = p_level
	archetype = p_archetype
	skills = p_skills
	perks = p_perks
	equipment = p_equipment
	deck = p_deck
	statPointsHealth = p_statPointsHealth
	statPointsAttack = p_statPointsAttack
	statPointsDefense = p_statPointsDefense
	statPointsMobility = p_statPointsMobility
	

func loadDictionary(input:Dictionary):
	name = input.name
	level = input.level
	archetype = input.archetype
	statPointsHealth = input.statPointsHealth
	statPointsAttack = input.statPointsAttack
	statPointsDefense = input.statPointsDefense
	statPointsMobility = input.statPointsMobility
	skills = input.skills
	perks = input.perks
	equipment = input.equipment
	deck = input.deck
	
func calcBaseStatline() -> Statline:
	return Manifest.archetypes[archetype].determineStats(statPointsHealth,statPointsAttack,statPointsDefense,statPointsMobility)
