extends Resource
class_name GameBoard

const ManhattanNeighbours = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
const DiagonalNeighbours = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN,Vector2i.LEFT+Vector2i.UP,Vector2i.LEFT+Vector2i.DOWN,Vector2i.RIGHT + Vector2i.UP, Vector2i.RIGHT + Vector2i.DOWN]
var NeighborsType = ManhattanNeighbours
#Board should store map data loaded from the file. Primarily used for world geometry
@export var board: Array[Array] = []
#Data used to determine where to spawn players
@export var spawnPointsUnits: Array[Vector2i] = []
@export var spawnPointsNPC: Array[Vector2i] = []
@export var spawnPointsEquipment: Array[Vector2i] = []
@export var spawnPointsRelic: Array[Vector2i] = []
#Storage for pathfinding via Dmap like implementation
var dGrid = []
@export var size = 0
@export var _units: = {}
@export var _equipment: = {}
@export var _equipmentQueue: = {}
@export var _traps: = {}
@export var relicLoc = {}

var SearchCount = 0

func startMatch():
	for x in _equipmentQueue:
		loadEquipment(_equipmentQueue[x])
	pass

func loadEquipment(EquipmentToSpawn: Equipment, position: Vector2i = Vector2i(-1,-1) ):
	if (position == Vector2i(-1,-1)):
		var equipPos = getRandomUnoccupiedSpawn(spawnPointsEquipment)
		if (equipPos != Vector2i.ZERO):
			_equipment.get_or_add(getRandomUnoccupiedSpawn(spawnPointsEquipment),EquipmentToSpawn)
		else:
			_equipmentQueue.get_or_add(EquipmentToSpawn.effecterID,EquipmentToSpawn)
	else:
		if (!_equipment.has(position)):
			_equipment.get_or_add(position,EquipmentToSpawn)
		else:
			for x in getNeighbors(position):
				loadEquipment(EquipmentToSpawn,x)

func loadNPCs(NPCsToSpawn: Array[int]):
	for NPC in NPCsToSpawn:
		print("placeholder")
	pass

func loadRelic():
	relicLoc = getRandomUnoccupiedSpawn(spawnPointsRelic)
	pass

func setBoardSimple(inputSize: int):
	size = inputSize
	for i in inputSize:
		board.append([])
		dGrid.append([])
		for j in inputSize:
			board[i].append(0)
			dGrid[i].append(20)
	size = inputSize

func exportTilemapToCsv():
	var file = FileAccess.open("user://Maps/saved_map.csv", FileAccess.WRITE)
	var string_array = PackedStringArray([])
	for x in (board.size()):
		string_array.clear()
		for y in (board[0].size()):
			string_array.append(str(board[x][y]))
		file.store_csv_line(string_array)
	file.close()

func loadCordinatestoBoard(input: Array[Array]):
	board.clear()
	var largestSize = 0
	for i in input.size():
		largestSize = max(largestSize,i+1)
		board.append([])
		for j in input[i].size():
			largestSize = max(largestSize,j+1)
			board[i].append(input[i][j])
			var cellValue = input[i][j]
			if (cellValue == 2):
				spawnPointsUnits.append(Vector2i(i,j))
			if (cellValue == 3):
				spawnPointsNPC.append(Vector2i(i,j))
			if (cellValue == 4):
				spawnPointsEquipment.append(Vector2i(i,j))
			if (cellValue == 5):
				spawnPointsRelic.append(Vector2i(i,j))
	
	for i in largestSize:
		if (i>=input.size()):
			board.append([])
		while (board[i].size() < largestSize):
			board[i].append(-1)

func getGameBoardAsVector2iArray() -> Array[Vector2i]:
	var output: Array[Vector2i] = []
	var i = 0
	var j = 0
	for x in board:
		j = 0
		for y in board[i]:
			if (board[i][j] > 0):
				output.append(Vector2i(i,j))
			j = j+1
		i = i + 1
	return output

func isOccupied(cell: Vector2i) -> bool:
	var occupied = false;
	if (board.size()-1 < cell.x || board.size()-1 < cell.y):
		occupied = true
	elif _units.has(Vector2i(cell.x,cell.y)):
		occupied = true;
	elif board[cell.x][cell.y] < 1:
		occupied = true;
	return occupied

func getRandomUnoccupiedSpawn(spawns: Array[Vector2i]) -> Vector2i:
	var possiblePoints: Array[Vector2i] = []
	for point in spawns:
		if(not _units.has(point) and not _equipment.has(point) and not relicLoc.has(point)):
			possiblePoints.append(point)
	if (possiblePoints.is_empty()):
		return Vector2i(0,0)
	else:
		return possiblePoints.pick_random()

func calculateDmap (inputTargets: PackedVector2Array,ObstructionsToIgnore: Array[Vector2i] = [], inputRange: int = 20):
	clearGrid()
	var cellsToCheck: PackedVector2Array
	for point in inputTargets:
		dGrid[point.x][point.y] = 0
		cellsToCheck.append(point)
	for cell in cellsToCheck:
		SearchCount += 1
		if (dGrid[cell.x][cell.y] > inputRange):
			continue
		for borderCell in getNeighbors(cell,ObstructionsToIgnore):
			if (dGrid[borderCell.x][borderCell.y] > dGrid[cell.x][cell.y] + 1):
				dGrid[borderCell.x][borderCell.y] = dGrid[cell.x][cell.y] + 1
				if (!cellsToCheck.has(borderCell)):
					cellsToCheck.append(borderCell)
				pass

func clearGrid():
	for x in size:
		for y in size:
			dGrid[x][y] = 20
	
func getNeighbors(input: Vector2i,  ObstructionsToIgnore: Array[Vector2i] = []) -> PackedVector2Array:
	var coordinates: Array
	for direction in NeighborsType:
		var result: Vector2i = input + direction
		if (!ObstructionsToIgnore.has(result) && (boundsCheck(result) || isOccupied(result))):
			continue
		coordinates.append(result)
	return coordinates
	
func display():
	var toPrintGrid = ""
	var toPrintWalkable = ""
	for i in dGrid.size():
		toPrintGrid += str(dGrid[i]) + "\n"
	print(toPrintGrid)
	print(toPrintWalkable)
	print(dGrid.size())
	print(str(SearchCount) + "SearchCount")
	SearchCount = 0
	
func boundsCheck(input: Vector2i) -> bool:
	return input.x > dGrid.size()-1 || input.y > dGrid.size()-1 || input.x < 0 || input.y < 0

func getCellsUnderDistance(inputDistance: int, inputTargets: PackedVector2Array):
	calculateDmap(inputTargets)
	display()
	var returns: Array[Vector2i] = []
	for x in size:
		for y in size:
			if dGrid[x][y] <= inputDistance:
				returns.append(Vector2i(x,y))
	return returns

func getPath(input:Vector2i, inputTargets: PackedVector2Array) -> PackedVector2Array:
	calculateDmap(inputTargets,[input])
	var currentLoc = input
	var path = [input]
	var matches = true
	while (dGrid[currentLoc.x][currentLoc.y] > 0 && matches):
		matches = false
		for borderCell in getNeighbors(currentLoc):
			if(dGrid[borderCell.x][borderCell.y] < dGrid[currentLoc.x][currentLoc.y]):
				currentLoc = borderCell
				path.append(currentLoc)
				matches = true
				break
	path.reverse()
	return path

@rpc("authority", "call_local","reliable")
func _moveUnit(inputUnit: Vector2i,new_cell: Vector2i) -> void:
	var PathTaken: PackedVector2Array = []
	var unitToMove = _units[inputUnit]
	_units.erase(unitToMove.cell)
	_units[new_cell] = unitToMove
	PathTaken = unitToMove.walk_along(getPath(new_cell,[unitToMove.cell]))
	unitToMove.changePosition(PathTaken[PathTaken.size()-1])
	SignalManager.UnitMoved.emit(unitToMove,PathTaken)
	# Finally, we clear the `_active_unit`, which also clears the `_walkable_cells` array.

@rpc("authority", "call_local","reliable")	
func _teleportUnit(inputUnit: Vector2i,new_cell: Vector2i) -> void:
	var unitToMove = _units[inputUnit]
	_units.erase(unitToMove.cell)
	_units[new_cell] = unitToMove
	SignalManager.UnitTeleported.emit(unitToMove,new_cell)
	unitToMove.changePosition(new_cell)
	# Finally, we clear the `_active_unit`, which also clears the `_walkable_cells` array.
