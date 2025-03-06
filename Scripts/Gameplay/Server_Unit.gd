extends Resource
class_name Server_Unit

var cell: Vector2i = Vector2i(0,0)
var player: int = 0
var unitID: int = 0
var interupt: bool = false
var is_selected: bool = false
var readyToEndTurn: bool = false

var sheet:CharacterSheet = CharacterSheet.new():
	set(value):
		sheet = value
		baseStats = sheet.calcBaseStatline()
		loadPublicInfo()
@export var baseStats: Statline
@export var skills: Array[Skill]
@export var perks: Array[Perk]
@export var equipment: Array[Equipment]
signal endTurn

var publicInfo: Server_Unit_Public_Info = Server_Unit_Public_Info.new()

func walk_along(path: PackedVector2Array) -> PackedVector2Array:
	for point in path:
		if(interupt):
			return path.slice(0,path.find(point)+1)
	ReadyTurnEnd()
	return path

func changePosition(input: Vector2i):
	cell = input
func ReadyTurnEnd():
	endTurn.emit()

func loadSkills(IDs: Array[int] = []):
	skills.clear()
	if (IDs == []):
		for x in sheet.skills:
			skills.append(MatchServer.registerNewSkill(x))
	else:
		var x: int = 0
		while (x < sheet.skills.size()):
			skills.append(MatchServer.registerNewSkill(sheet.skills[x],IDs[x]))
			x = x + 1

func loadPerks(IDs: Array[int] = []):
	perks.clear()
	if (IDs == []):
		for x in sheet.perks:
			perks.append(MatchServer.registerNewPerk(x))
	else:
		var x: int = 0
		while (x < sheet.perks.size()):
			perks.append(MatchServer.registerNewPerk(sheet.perks[x],IDs[x]))
			x = x + 1

func loadEquipment(IDs: Array[int] = []):
	equipment.clear()
	if (IDs == []):
		for x in sheet.equipment:
			equipment.append(MatchServer.registerNewEquipment(x))
	else:
		var x: int = 0
		while (x < sheet.equipment.size()):
			equipment.append(MatchServer.registerNewEquipment(sheet.equipment[x],IDs[x]))
			x = x + 1

func calculateStats() -> Statline:
	var statResult: Statline = baseStats
	for x in skills:
		statResult = statResult.combineStats(x.statModifier)
	for x in perks:
		statResult = statResult.combineStats(x.statModifier)
	for x in equipment:
		statResult = statResult.combineStats(x.statModifier)
	return statResult

func loadPublicInfo():
	publicInfo.displaySkills.clear()
	publicInfo.displayPerks.clear()
	publicInfo.displayEquipment.clear()
	for x in perks:
		publicInfo.displayPerks.append(x.typeID)
	for x in skills:
		publicInfo.displaySkills.append(x.typeID)
	for x in equipment:
		publicInfo.displayEquipment.append(x.typeID)
	publicInfo.displayHealth = baseStats.health
	publicInfo.displayMaxHealth = baseStats.health
	publicInfo.displayAttack = baseStats.attack
	publicInfo.displayDefense = baseStats.defense
	publicInfo.displayMobility = baseStats.mobility
	
func getMobility():
	if (MatchServer.multiplayer.get_unique_id() == player):
		var tempStat = calculateStats()
		return tempStat.mobility * tempStat.mobilityMod
	else:
		return publicInfo.displayMobility

func getAttack():
	if (MatchServer.multiplayer.get_unique_id() == player):
		var tempStat = calculateStats()
		return tempStat.attack * tempStat.attack
	else:
		return publicInfo.displayAttack
		
func getDefense():
	if (MatchServer.multiplayer.get_unique_id() == player):
		var tempStat = calculateStats()
		return tempStat.defense * tempStat.defense
	else:
		return publicInfo.displayDefense
