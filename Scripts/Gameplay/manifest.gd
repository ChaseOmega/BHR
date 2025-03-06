extends Node
@export var archetypes: Array[Archetype] = []
@export var skills: Array[Skill] = []
@export var perks: Array[Perk] = []
@export var cards: Array[Card] = []
@export var equipment: Array[Equipment]
enum testEnum {Archetype,Skill,Perk,Card,Equipment}

func getCardFromID(cardID: int) -> Card:
	if (cards.size() > cardID):
		return cards[cardID]
	return null

func getSkillFromID(skillID: int) -> Skill:
	if (skills.size() > skillID):
		return skills[skillID]
	return null

func getPerkFromID(perkID: int) -> Perk:
	if (perks.size() > perkID):
		return perks[perkID]
	return null

func getEquipmentFromID(equipmentID: int) -> Equipment:
	if (equipment.size() > equipmentID):
		return equipment[equipmentID]
	return null
