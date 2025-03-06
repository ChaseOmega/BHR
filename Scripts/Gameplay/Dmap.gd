class_name Dmap

var size = 12
var grid = []
var obstructionGrid = []
var SearchCount = 0

const ManhattanNeighbours = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
const DiagonalNeighbours = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN,Vector2i.LEFT+Vector2i.UP,Vector2i.LEFT+Vector2i.DOWN,Vector2i.RIGHT + Vector2i.UP, Vector2i.RIGHT + Vector2i.DOWN]

var NeighborsType = ManhattanNeighbours

#constructors
static func createSimple(inputSize: int) -> Dmap:
		var instance = Dmap.new()
		instance.size = inputSize
		for i in instance.size:
			instance.grid.append([])
			for j in instance.size:
				instance.grid[i].append(20)
		for i in instance.size:
			instance.obstructionGrid.append([])
			for j in instance.size:
				instance.obstructionGrid[i].append(false)
		return instance
static func createWithObstruction(inputSize: int, Obstructions: PackedVector2Array) -> Dmap:
		var instance = Dmap.new()
		instance.size = inputSize
		for i in instance.size:
			instance.grid.append([])
			for j in instance.size:
				instance.grid[i].append(255)
		for i in instance.size:
			instance.obstructionGrid.append([])
			for j in instance.size:
				instance.obstructionGrid[i].append(false)
		for walls in Obstructions:
			instance.obstructionGrid[walls.x][walls.y] = true
		return instance

func updateObstructions(Obstructions: PackedVector2Array):
	for x in size:
		for y in size:
			obstructionGrid[x][y] = false
	for walls in Obstructions:
			obstructionGrid[walls.x][walls.y] = true
func removeObstruction(input: Vector2i):
	obstructionGrid[input.x][input.y] = false
func addObstruction(input: Vector2i):
	obstructionGrid[input.x][input.y] = true


func CalculateDmap (inputTargets: PackedVector2Array, inputRange: int = 20):
	clearGrid()
	var cellsToCheck: PackedVector2Array
	for point in inputTargets:
		grid[point.x][point.y] = 0
		cellsToCheck.append(point)
	
	for cell in cellsToCheck:
		SearchCount += 1
		if (grid[cell.x][cell.y] > inputRange):
			continue
		for borderCell in get_neighbors(cell):
			if (grid[borderCell.x][borderCell.y] > grid[cell.x][cell.y] + 1):
				grid[borderCell.x][borderCell.y] = grid[cell.x][cell.y] + 1
				if (!cellsToCheck.has(borderCell)):
					cellsToCheck.append(borderCell)
				pass
				
func CalculateDmapIgnoreObstructions (inputTargets: PackedVector2Array, inputRange: int = 20):
	clearGrid()
	var cellsToCheck: PackedVector2Array
	for point in inputTargets:
		grid[point.x][point.y] = 0
		cellsToCheck.append(point)
	
	for cell in cellsToCheck:
		SearchCount += 1
		if (grid[cell.x][cell.y] > inputRange):
			continue
		for borderCell in get_neighborsIgnoreObstructions(cell):
			if (grid[borderCell.x][borderCell.y] > grid[cell.x][cell.y] + 1):
				grid[borderCell.x][borderCell.y] = grid[cell.x][cell.y] + 1
				if (!cellsToCheck.has(borderCell)):
					cellsToCheck.append(borderCell)
				pass
func clearGrid():
	for x in size:
		for y in size:
			grid[x][y] = 20
	
func get_neighbors(input: Vector2i) -> PackedVector2Array:
	var coordinates: Array
	for direction in NeighborsType:
		var result: Vector2i = input + direction
		if (boundsCheck(result) || obstructionGrid[result.x][result.y]):
			continue
		coordinates.append(result)
	return coordinates

func get_neighborsIgnoreObstructions(input: Vector2i) -> PackedVector2Array:
	var coordinates: Array
	for direction in NeighborsType:
		var result: Vector2i = input + direction
		if (boundsCheck(result)):
			continue
		coordinates.append(result)
	return coordinates
	
func display():
	var toPrintGrid = ""
	var toPrintWalkable = ""
	for i in grid.size():
		toPrintGrid += str(grid[i]) + "\n"
		toPrintWalkable += str(obstructionGrid[i]) + "\n"
	print(toPrintGrid)
	print(toPrintWalkable)
	print(grid.size())
	print(SearchCount)
	
func boundsCheck(input: Vector2i) -> bool:
	return input.x > grid.size()-1 || input.y > grid.size()-1 || input.x < 0 || input.y < 0

func getCellsUnderDistance(inputDistance: int, inputTargets: PackedVector2Array):
	CalculateDmap(inputTargets)
	display()
	var returns: Array[Vector2i] = []
	for x in size:
		for y in size:
			if grid[x][y] <= inputDistance:
				returns.append(Vector2i(x,y))
	return returns

func getPath(input:Vector2i, inputTargets: PackedVector2Array) -> PackedVector2Array:
	CalculateDmap(inputTargets)
	var currentLoc = input
	var path = [input]
	var matches = true
	removeObstruction(inputTargets[0])
	while (grid[currentLoc.x][currentLoc.y] > 0 && matches):
		matches = false
		for borderCell in get_neighbors(currentLoc):
			if(grid[borderCell.x][borderCell.y] < grid[currentLoc.x][currentLoc.y]):
				currentLoc = borderCell
				path.append(currentLoc)
				matches = true
				break
	path.reverse()
	return path
