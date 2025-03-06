extends Node

const ManhattanDirections = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
const DiagonalDirections = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN,Vector2i.LEFT+Vector2i.UP,Vector2i.LEFT+Vector2i.DOWN,Vector2i.RIGHT + Vector2i.UP, Vector2i.RIGHT + Vector2i.DOWN]
var DirectionsType = ManhattanDirections
var turnPlayer: int = 0
var playerOrder: Array[int] = []
var players: = {}
var board: GameBoard = GameBoard.new()


@export var skills = {}
@export var perks: = {}
@export var cards: = {}
@export var equipment: = {}
@export var effecters: = {}
@export var units: = {}

@export var mapEquipment = {}



@export var deck: Deck = Deck.new()

func _ready() -> void:
	pass

func displayInfo(toDisplay:displayable):
	MatchServer.requestDisplayInfo.emit(toDisplay)
	pass

#These functions are used to start the match. These should only be called when starting a match
#region matchStartup
func startMatch():
	_loadCsvToGameBoard()
	_loadPlayerOrder()
	_loadMatchPlayers()
	deck.shuffle()
	_syncMatchPlayersCards()
	_spawnRegisteredPlayers()
	board.startMatch()
func _loadCsvToGameBoard():
	var _dir = DirAccess.open("user://Maps/")
	var file
	var boardToLoad: Array[Array] = []
	if (Lobby.mapToLoad == ""):
		file = FileAccess.open("user://Maps/saved_map.csv", FileAccess.READ)
		print("Can't find it chief")
	else:
		file = FileAccess.open("user://Maps/" + Lobby.mapToLoad, FileAccess.READ)
	var x: int = 0
	var y: int = 0
	while (!file.eof_reached()):
		boardToLoad.append([])
		x = 0
		for z in file.get_csv_line():
			if (file.eof_reached()):
				boardToLoad.pop_back()
				break
			boardToLoad[y].append(int(z))
			x = x + 1
		y = y+1
	file.close()
	loadCordinatestoBoard.rpc(boardToLoad)
	pass
func _loadPlayerOrder():
	for x in Lobby.playerinfo:
		_addPlayerToOrder.rpc(x)
func _loadMatchPlayers():
	var playerAdded:Match_Player
	for x in Lobby.playerinfo:
		_addPlayer.rpc(x)
		playerAdded = players.get(x)
		playerAdded.playerName = Lobby.playerinfo[x].userName
func _loadMatchEquipment():
	var equipmentAdded:Equipment
	for x in Lobby.playerinfo:
		_addPlayer.rpc(x)
func _loadMatchNPCs():
	pass
func _loadMatchRelic():
	pass

func _spawnRegisteredPlayers():
	for x in Lobby.playerinfo:
		addUnit(x,board.getRandomUnoccupiedSpawn(board.spawnPointsUnits),inst_to_dict(Lobby.playerinfo[x].characterSheet))
	SignalManager.UnitsSpawned.emit()
	pass
@rpc("authority","call_local","reliable")
func loadCordinatestoBoard(input: Array[Array]):
	board.setBoardSimple(input.size())
	print(input.size())
	board.loadCordinatestoBoard(input)

@rpc("authority","call_local","reliable")
func _addPlayer(playerID: int):
	players.get_or_add(playerID,Match_Player.new())

@rpc("authority","call_local","reliable")
func _addPlayerToOrder(input: int):
	playerOrder.append(input)
#endregion

#Functions to update a player's public info. Do not use these to pass info that you do not want public.
#region Players
func updatePlayerPublicInfoRequest():
	if (multiplayer.get_unique_id() == 1):
		for x in players:
			print("Test")
			_updatePlayerPublicPrep(x)
	pass

func _updatePlayerPublicPrep(playerID: int):
	var targetPlayer: Match_Player = players[playerID]
	var playerInfoToSend: Dictionary = inst_to_dict(targetPlayer.publicInfo)
	_updatePlayerPublic.rpc(playerID,playerInfoToSend)
@rpc("authority","call_remote","reliable")
func _updatePlayerPublic(playerID: int, info:Dictionary):
	var targetPlayer: Match_Player = players[playerID]
	targetPlayer.publicInfo.loadDictionary(info)
	SignalManager.RefreshUI.emit()
	pass
#endregion

#region UnitManagement
func addUnit(playerToAssign: int, unitPosition: Vector2i,inputSheet: Dictionary):
	var createdUnit: Server_Unit = registerNewUnit()
	createdUnit.cell = unitPosition
	createdUnit.player = playerToAssign
	var sheetToLoad: CharacterSheet = CharacterSheet.new()
	sheetToLoad.loadDictionary(inputSheet)
	createdUnit.sheet = sheetToLoad
	createdUnit.loadSkills()
	createdUnit.loadEquipment()
	createdUnit.loadPerks()
	#createdUnit.sheet = Lobby.playerinfo[playerToAssign].
	players[playerToAssign].addUnit(createdUnit)
	board._units.get_or_add(createdUnit.cell,createdUnit)
	addUnitPublicPrep(createdUnit)

func addUnitPublicPrep(unit:Server_Unit):
	addUnitPublic.rpc(unit.player,unit.cell,unit.unitID,inst_to_dict(unit.publicInfo))
	syncUnitPrivate.rpc_id(unit.player,unit.unitID,inst_to_dict(unit.sheet))
	unitEffectersPrep(unit.unitID)
	pass

@rpc("authority","call_remote","reliable")	
func addUnitPublic(playerToAssign: int, unitPosition: Vector2i,unitID: int,inputSheet: Dictionary):
	var createdUnit: Server_Unit = registerNewUnit(unitID)
	createdUnit.cell = unitPosition
	createdUnit.player = playerToAssign
	createdUnit.publicInfo.loadDictionary(inputSheet)
	players[playerToAssign].addUnit(createdUnit)
	board._units.get_or_add(createdUnit.cell,createdUnit)
	pass

@rpc("authority","call_remote","reliable")	
func syncUnitPrivate(unitID: int,inputSheet: Dictionary):
	var sheetToLoad: CharacterSheet = CharacterSheet.new()
	sheetToLoad.loadDictionary(inputSheet)
	units[unitID].sheet = sheetToLoad
	pass

func unitEffectersPrep(unitID: int):
	var targetUnit: Server_Unit = units[unitID]
	var skillIDs: Array[int] = []
	var perkIDs: Array[int] = []
	var equipmentIDs: Array[int] = []
	for x in targetUnit.skills:
		skillIDs.append(x.effecterID)
	for x in targetUnit.perks:
		perkIDs.append(x.perkID)
	for x in targetUnit.equipment:
		equipmentIDs.append(x.effecterID)
	addUnitSkills.rpc_id(targetUnit.player,unitID,skillIDs)
	addUnitPerks.rpc_id(targetUnit.player,unitID,perkIDs)
	addUnitEquipment.rpc_id(targetUnit.player,unitID,equipmentIDs)
	pass

@rpc("authority","call_remote","reliable")	
func addUnitSkills(unitID: int,inputIDs: Array[int]):
	var unit: Server_Unit = units[unitID]
	unit.loadSkills(inputIDs)
	pass

@rpc("authority","call_remote","reliable")	
func addUnitPerks(unitID: int,inputIDs: Array[int]):
	var unit: Server_Unit = units[unitID]
	unit.loadPerks(inputIDs)
	pass

@rpc("authority","call_remote","reliable")	
func addUnitEquipment(unitID: int,inputIDs: Array[int]):
	var unit: Server_Unit = units[unitID]
	unit.loadEquipment(inputIDs)
	pass
#endregion


#Function used to alter the overall game state. Declare a winner, end the game, pass turns ect.
#region Gameflow Controls
@rpc("any_peer","call_local","reliable")
func requestTurnEnd():
	if(multiplayer.get_unique_id() == 1):
		_turnEnd.rpc()
@rpc("authority","call_local","reliable")
func _turnEnd():
		turnPlayer += 1
		if (turnPlayer >= playerOrder.size()):
			turnPlayer = 0
#endregion

#Functions for adding cards to the deck. Primarily used during setup of match.
#region AddToDeck
@rpc("any_peer","call_local","reliable")
func _addCardToDeckRequest(input: int):
	if(multiplayer.get_unique_id() == 1):
		registerNewCard(input,multiplayer.get_remote_sender_id())
@rpc("any_peer","call_local","reliable")
func _addCardArrayToDeckRequest(input: Array[int]):
	if(multiplayer.get_unique_id() == 1):
		_addCardArrayToDeck(input,multiplayer.get_remote_sender_id())
func _addCardArrayToDeck(cardArray: Array[int], playerID:int):
	for card in cardArray:
		registerNewCard(card,playerID)
#endregion

#Functions that basically add a piece of equipment to the map. This is not an elegant solution.

#region AddToMapEquipment
@rpc("any_peer","call_local","reliable")
func _addEquipmentToMapRequest(input: int):
	if(multiplayer.get_unique_id() == 1):
		_addEquipmentToMap(input,multiplayer.get_remote_sender_id())
@rpc("any_peer","call_local","reliable")
func _addEquipmentArrayToMapRequest(input: Array[int]):
	if(multiplayer.get_unique_id() == 1):
		_addEquipmentArrayToMap(input,multiplayer.get_remote_sender_id())
func _addEquipmentArrayToMap(equipmentArray: Array[int], playerID:int):
	var equipmentAdded:Equipment
	for equipment in equipmentArray:
		_addEquipmentToMap(equipment,playerID)
func _addEquipmentToMap(equipment: int, playerID:int):
	var equipmentAdded:Equipment
	equipmentAdded = registerNewEquipment(equipment)
	board._equipmentQueue.get_or_add(equipmentAdded.effecterID,equipmentAdded)
#endregion


#Functions for syncing card state among players. Should only be used by server.
#region SyncCards
func _syncMatchPlayersCards():
	for player in players:
		_syncMatchPlayerCardsPrep(player)
		SignalManager.RefreshUI.emit()
func _syncMatchPlayerCardsPrep(playerID: int):
	var targetPlayer: Match_Player = players[playerID]
	var targetCards: Array[Card] = targetPlayer.cards
	var cardInfoToSend: Array[Dictionary] = []
	for card in targetCards:
		cardInfoToSend.append(inst_to_dict(card))
	targetPlayer.publicInfo.numberOfCards = targetPlayer.cards.size()
	_syncMatchPlayerCards.rpc_id(playerID,playerID,cardInfoToSend)
@rpc("authority","call_remote","reliable")
func _syncMatchPlayerCards(playerID: int, Cards: Array[Dictionary]):
	var targetPlayer: Match_Player = players[playerID]
	targetPlayer.cards.clear()
	#I need to make this load card data, test once we have a card that actually keeps something like a persistant counter on it.
	for card in Cards:
		var cardToAdd: Card = Manifest.getCardFromID(card.typeID)
		cardToAdd.loadDictionary(card)
		targetPlayer.cards.append(cardToAdd)
	SignalManager.RefreshUI.emit()
#endregion
#functions to allow for a player to draw a card
#region actionDrawCard

@rpc("any_peer", "call_local","reliable")
func drawCardPlayerRequest():
	if (multiplayer.get_unique_id() == 1):
		drawCardPlayer(multiplayer.get_remote_sender_id())
	pass
func drawCardPlayer(playerID: int):
	var drawnCard: Card = drawCard()
	var player: Match_Player = players[playerID]
	if (drawnCard == null):
		return
	player.cards.append(drawnCard)
	_syncMatchPlayersCards()
	#Give the card to a player on the server, then update the player with this information.
	#Update all players on the new number of cards this player has, but not which card.
	pass
#Functions used by the game for players to draw cards
func drawCard() -> Card:
	return deck.drawCard()	

#endregion

#functions to allow for a player to use a card's generic effect. Start by using request
#region actionCardGeneric
@rpc("any_peer", "call_local","reliable")
func cardGenericActivationRequest(cardID: int,user:Vector2i):
	if (multiplayer.get_unique_id() == 1):
		_cardGenericActivation(cardID,board._units[user])
	pass

func _cardGenericActivation(cardID: int, user: Server_Unit):
	var cardToActivate: Card = effecters[cardID]
	cardToActivate.genericEffect(user)
	#Give the card to a player on the server, then update the player with this information.
	#Update all players on the new number of cards this player has, but not which card.
	pass
#endregion

#region EffecterHandling
func effectActivationClientPrep(inputEffecter: Effecter, user: Server_Unit):
	var targets = await inputEffecter.effectTargeting(user)
	if (targets == []):
		return
	effectActivationRequest.rpc(inputEffecter.effecterID,user.cell,targets)

@rpc("any_peer", "call_local","reliable")
func effectActivationRequest(effectID: int, user:Vector2i ,targets):
	if (multiplayer.get_unique_id() == 1):
		if(effecters[effectID].effectCondition(board._units[user])):
			effectActivation(effecters[effectID],board._units[user],targets)
	pass

func effectActivation(ToActivate: Effecter,user: Server_Unit, target):
	ToActivate.effect(user,target)
	#Give the card to a player on the server, then update the player with this information.
	#Update all players on the new number of cards this player has, but not which card.
	pass	
#endregion
#You need to use another more specific register function, this one is entirely used as a helper
func _registerNewEffecter(effecterToRegister: Effecter):
	effecters.get_or_add(effecterToRegister.effecterID,effecterToRegister)
	pass

#region RegisterEffects
func registerNewSkill(skillID: int,instanceID: int = 0) -> Skill:
	var newSkill: Skill = Manifest.skills[skillID].duplicate()
	if (instanceID == 0):
		skills.get_or_add(newSkill.get_instance_id(),newSkill)
		newSkill.effecterID = newSkill.get_instance_id()
	else:
		skills.get_or_add(instanceID,newSkill)
		newSkill.effecterID = instanceID
	_registerNewEffecter(newSkill)

	return newSkill

func registerNewPerk(perkID: int,instanceID: int = 0) -> Perk:
	var newPerk: Perk = Manifest.perks[perkID].duplicate()
	if (instanceID == 0):
		perks.get_or_add(newPerk.get_instance_id(),newPerk)
		newPerk.perkID = newPerk.get_instance_id()
	else:
		perks.get_or_add(instanceID,newPerk)
		newPerk.perkID = instanceID

	return newPerk

func registerNewEquipment(equipmentID: int,instanceID: int = 0) -> Equipment:
	var newEquipment: Equipment = Manifest.equipment[equipmentID].duplicate()
	if (instanceID == 0):
		equipment.get_or_add(newEquipment.get_instance_id(),newEquipment)
		newEquipment.effecterID = newEquipment.get_instance_id()
	else:
		equipment.get_or_add(instanceID,newEquipment)
		newEquipment.effecterID = instanceID
	_registerNewEffecter(newEquipment)
	return newEquipment

func registerNewCard(typeID: int, playerID:int,instanceID: int = 0) -> Card:
	var newCard: Card = Manifest.getCardFromID(typeID).duplicate()
	newCard.source = playerID
	newCard.typeID = typeID
	if (instanceID == 0):
		cards.get_or_add(newCard.get_instance_id(),newCard)
		newCard.effecterID = newCard.get_instance_id()
	else:
		cards.get_or_add(instanceID,newCard)
		newCard.effecterID = instanceID
	_registerNewEffecter(newCard)
	deck.addCardtoLive(newCard)

	return newCard

func registerNewUnit(instanceID: int = 0) -> Server_Unit:
	var newUnit:Server_Unit = Server_Unit.new()
	if (instanceID == 0):
		units.get_or_add(newUnit.get_instance_id(),newUnit)
	else:
		units.get_or_add(instanceID,newUnit)
	newUnit.unitID = units.find_key(newUnit)
	return newUnit

#endregion


#Functions to request a unit to be moved. use Prep to start movement.
#region actionMovement
func moveUnitPrep(inputUnit: Vector2i):
	var toReturn = await requestPlayerSelectCells(getWalkableCells(board._units[inputUnit]),1)
	if toReturn == []:
		return
	_moveUnitRequest.rpc(inputUnit,toReturn[0])
	return
@rpc("any_peer", "call_local","reliable")
func _moveUnitRequest(inputUnit: Vector2i, DestinationCell: Vector2i) -> bool:
	if (multiplayer.get_unique_id() == 1):
		_moveUnitCheck(inputUnit,DestinationCell, multiplayer.get_remote_sender_id())
	return true
func _moveUnitCheck(inputUnit: Vector2i, DestinationCell: Vector2i, id: int) -> void:
	if(id != board._units[inputUnit].player):
		print("That's not your unit!")
	elif(board.isOccupied(DestinationCell)):
		print("There's something in the way!")
	elif (DestinationCell not in getWalkableCells(board._units[inputUnit])):
		print("That's out of your range!")
	elif (id != playerOrder[turnPlayer]):
		print("It's not your turn")
	else:
		_moveUnit.rpc(inputUnit,DestinationCell)
	pass
#endregion

#Functions that change unit positions. Do not call these by themselves and use an action Region instead.
#region movementRPCs
@rpc("authority", "call_local","reliable")
func _moveUnit(inputUnit: Vector2i,new_cell: Vector2i) -> void:
	board._moveUnit(inputUnit,new_cell)
	# Finally, we clear the `_active_unit`, which also clears the `_walkable_cells` array.

@rpc("authority", "call_local","reliable")	
func _teleportUnit(inputUnit: Vector2i,new_cell: Vector2i) -> void:
	board._teleportUnit(inputUnit,new_cell)
	# Finally, we clear the `_active_unit`, which also clears the `_walkable_cells` array.
#endregion

#Series of functions that all give certain range of cells for targeting.
#region CellGetters
func getWalkableCells(unit: Server_Unit) -> Array[Vector2i]:
	return board.getCellsUnderDistance(unit.getMobility(),[unit.cell])	

func getUnitsWithinRangeVector2Cardinal(searchRange:int,targetPos:Vector2i) -> Array[Server_Unit]:
	var positionsToReturn: Array[Server_Unit] = []
	var distance: int
	for u in board._units:
		distance = abs(targetPos.x - u.x) + abs(targetPos.y - u.y)
		print (str(abs(targetPos.x - u.x) + abs(targetPos.y - u.y)))
		if (distance <= searchRange):
			positionsToReturn.append(board._units[u])
	return positionsToReturn

func getUnitsWithinRangeVector2CardinalAsVector2i(searchRange:int,targetPos:Vector2i) -> Array[Vector2i]:
	var positionsToReturn: Array[Vector2i] = []
	var distance: int
	for u in board._units:
		distance = abs(targetPos.x - u.x) + abs(targetPos.y - u.y)
		print (str(abs(targetPos.x - u.x) + abs(targetPos.y - u.y)))
		if (distance <= searchRange):
			positionsToReturn.append(board._units[u].cell)
	return positionsToReturn

func getUnitsWithinRangeUnit(searchRange:int,targetUnit:Server_Unit, includeSelf: bool = true) -> Array[Server_Unit]:
	var returnArray: Array[Server_Unit] = getUnitsWithinRangeVector2Cardinal(searchRange,targetUnit.cell)
	if (!includeSelf):
		returnArray.remove_at(returnArray.find(targetUnit))
	return returnArray

func getUnitsWithinRangeUnitAsVector2i(searchRange:int,targetUnit:Server_Unit, includeSelf: bool = true) -> Array[Vector2i]:
	var returnArray: Array[Vector2i] = getUnitsWithinRangeVector2CardinalAsVector2i(searchRange,targetUnit.cell)
	if (!includeSelf):
		returnArray.remove_at(returnArray.find(targetUnit.cell))
	return returnArray

func getCellsWithinRangeVector2Cardinal(searchRange:int,targetPos:Vector2i) -> Array[Vector2i]:
	var returnCells: Array[Vector2i] = []
	for x in range(targetPos.x - searchRange, targetPos.x + searchRange+1):
		for y in range(targetPos.y - searchRange + abs(targetPos.x - x), targetPos.y + searchRange+1 - abs(targetPos.x - x)):
			if (!board.boundsCheck(Vector2i(x,y))):
				returnCells.append(Vector2i(x,y))
	return returnCells

func getCellsWithinRangeUnit(searchRange:int,targetUnit:Server_Unit, includeSelf: bool = true) -> Array[Vector2i]:
	var returnCells: Array[Vector2i] = getCellsWithinRangeVector2Cardinal(searchRange,targetUnit.cell)
	if (!includeSelf):
		returnCells.remove_at(returnCells.find(targetUnit.cell))
	return returnCells

func getCellsWithinRangeVector2Geometry (searchRange:int,targetPos:Vector2i) -> Array[Vector2i]:
	var returnCells: Array[Vector2i] = []
	for cell in getCellsWithinRangeVector2Cardinal(searchRange,targetPos):
		if (board.board[cell.x][cell.y] > 0):
			returnCells.append(cell)
	return returnCells

func getCellsWithinRangeUnitGeometry(searchRange:int,targetUnit:Server_Unit, includeSelf: bool = true) -> Array[Vector2i]:
	var returnCells: Array[Vector2i] = getCellsWithinRangeVector2Geometry(searchRange,targetUnit.cell)
	if (!includeSelf):
		returnCells.remove_at(returnCells.find(targetUnit.cell))
	return returnCells

func getCellsWithinRangeVector2Unoccupied(searchRange:int,targetPos:Vector2i) -> Array[Vector2i]:
	var returnCells: Array[Vector2i] = []
	for cell in getCellsWithinRangeVector2Geometry(searchRange,targetPos):
		if (!board.isOccupied(cell)):
			returnCells.append(cell)
	return returnCells

func getCellsWithinRangeUnitUnoccupied(searchRange:int,targetUnit:Server_Unit, includeSelf: bool = true) -> Array[Vector2i]:
	var returnCells: Array[Vector2i] = getCellsWithinRangeVector2Unoccupied(searchRange,targetUnit.cell)
	if (!includeSelf):
		returnCells.remove_at(returnCells.find(targetUnit.cell))
	return returnCells

func getCellsPathableWithinRangeVector2Pathing(searchRange:int,targetPos:Vector2i) -> Array[Vector2i]:
	return board.getCellsUnderDistance(searchRange,[targetPos])

func getCellsPathableWithinRangeUnitPathing(searchRange:int,targetUnit:Server_Unit) -> Array[Vector2i]:
	return board.getCellsUnderDistance(searchRange,[targetUnit.cell])
#endregion

#Used to request a user to input a target for various functions.
#region TargetingRequests
func requestPlayerSelectCells(options:Array[Vector2i], numberRequested: int):
	SignalManager.requestPlayerInputCell.emit(options,numberRequested)
	var response: Array[Vector2i] = await SignalManager.responsePlayerInputCell
	return response

func requestPlayerSelectPlayers(options: Array[int], numberRequested: int):
	SignalManager.requestPlayerInputPlayer.emit(options,numberRequested)
	var response: Array[int] = await SignalManager.responsePlayerInputPlayer
	return response
#endregion
