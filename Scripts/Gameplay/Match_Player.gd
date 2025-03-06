extends Resource
class_name Match_Player

#Private Data
#This should only be updated on the server and the player who is control of the unit, unless explicitly needed
var playerName: String = "TestPlayer"
var cards: Array[Card]
var playerUnit: Server_Unit:
	set(value):
		playerUnit = value
		publicInfo.playerUnit = value
		updatePublicInfo()
var units: Array[Server_Unit]

#Public Data
#This should be updated to all players.
var publicInfo: Match_Player_Public_Info = Match_Player_Public_Info.new()

func _init(p_cards: Array[Card] = [],p_playerUnit: Server_Unit = null, p_subUnits: Array[Server_Unit] = [] , p_PublicInfo: Match_Player_Public_Info = Match_Player_Public_Info.new()):
	cards = p_cards
	playerUnit = p_playerUnit
	units = p_subUnits
	publicInfo = p_PublicInfo

func getPublicInfoAsDict() -> Dictionary:
	return inst_to_dict(publicInfo)
func getCardsAsDict() -> Array[Dictionary]:
	var returnArray = []
	for x in cards:
		returnArray.add(inst_to_dict(x))
	return returnArray

func updatePublicInfo():
	publicInfo.playerName = playerName
	#if (playerUnit != null):
		#publicInfo.Attack = playerUnit.sheet.stats.attack
		#publicInfo.Defense = playerUnit.sheet.stats.defense
		#publicInfo.Mobility = playerUnit.sheet.stats.mobility

func addUnit(input:Server_Unit):
	if (playerUnit == null):
		playerUnit = input
	units.append(input)
	input.endTurn.connect(endTurn)

func endTurn():
	var readyToEndTurn: bool = true
	for x in units:	
		if (x.readyToEndTurn):
			readyToEndTurn = false
	if(endTurn):
		for x in units:
			x.readyToEndTurn = false
		MatchServer.requestTurnEnd.rpc()
		
