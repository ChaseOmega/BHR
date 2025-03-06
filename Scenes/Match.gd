class_name Match
extends Node2D

const ManhattanDirections = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
const DiagonalDirections = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN,Vector2i.LEFT+Vector2i.UP,Vector2i.LEFT+Vector2i.DOWN,Vector2i.RIGHT + Vector2i.UP, Vector2i.RIGHT + Vector2i.DOWN]
var DirectionsType = ManhattanDirections

@export var grid: Resource = preload("res://Grid.tres")

var debug = false
var _units := {}
@export var unitBase: PackedScene
var _active_unit: Unit
var _walkable_cells: Array[Vector2i] = []
@export var _spawn_Points:Array[Vector2i] = []

@onready var _unit_overlay: UnitOverlay = $UnitOverlay
@onready var Visualmap: TileMapLayer = $TileMapLayer
signal UnitsSpawned
signal MapLoaded
var tmRect
var map: Dmap

func _ready() -> void:
	if(multiplayer.get_unique_id() == 1):
		loadCsvToTilemap()
		_spawnRegisteredPlayers.rpc(Lobby.playerinfo)
	else:
		await UnitsSpawned
	_reinitialize()
	refresh_occupied()


func is_occupied(cell: Vector2i) -> bool:
	var occupied = false;
	if (_active_unit != null):
		if (cell == Vector2i(_active_unit.cell)):
			return false
	if _units.has(Vector2i(cell.x,cell.y)):
		occupied = true;
	if not Visualmap.get_used_cells().has(Vector2i(cell)):
		occupied = true;
	return occupied
	
func _unhandled_input(event: InputEvent) -> void:
	if _active_unit and event.is_action_pressed("ui_cancel"):
		_deselect_active_unit()
		_clear_active_unit()
		
func refresh_occupied():
	for x in (tmRect.size[tmRect.size.max_axis_index()]):
		for y in (tmRect.size[tmRect.size.max_axis_index()]):
			if (is_occupied(Vector2i(x,y))):
				map.addObstruction(Vector2i(x,y))
			else:
				map.removeObstruction(Vector2i(x,y))

func get_walkable_cells(unit: Unit) -> Array[Vector2i]:
	return WalkCheck(unit.cell, unit.move_range)

@rpc("authority","call_local","reliable")
func _spawnRegisteredPlayers(input:Dictionary):
	var createdUnit: Unit
	for x in input:
		createdUnit = unitBase.instantiate()
		createdUnit.cell = _spawn_Points.front()
		_spawn_Points.erase(createdUnit.cell)
		createdUnit.position = Visualmap.map_to_local(createdUnit.cell)
		createdUnit.player = x
		add_child(createdUnit)
	emit_signal("UnitsSpawned")
	pass

func _reinitialize() -> void:
	_units.clear()

	for child in get_children():
		var unit := child as Unit
		if not unit:
			continue
		_units[unit.cell] = unit
		
func WalkCheck(Cell: Vector2i, range:int):
	var targets := [Cell]
	return map.getCellsUnderDistance(range,targets)

func _select_unit(cell: Vector2i) -> void:
	# Here's some optional defensive code: we return early from the function if the unit's not
	# registered in the `cell`.
	if not _units.has(cell):
		return
	
	_active_unit = _units[cell]
	_active_unit.set_is_selected(true)
	refresh_occupied()
	_walkable_cells = get_walkable_cells(_active_unit)
	_unit_overlay.draw(_walkable_cells)
	debug_distance()

func _deselect_active_unit() -> void:
	_active_unit.is_selected = false
	_unit_overlay.clear()

func _clear_active_unit() -> void:
	_active_unit = null
	_walkable_cells.clear()
	

@rpc("any_peer", "call_local","reliable")
func _move_unit_request(inputUnit: Vector2i, DestinationCell: Vector2i) -> bool:
	if (multiplayer.get_unique_id() == 1):
		_move_unit_Check(inputUnit,DestinationCell, multiplayer.get_remote_sender_id())
	return true
	
func _move_unit_Check(inputUnit: Vector2i, DestinationCell: Vector2i, id: int) -> void:
	if(!is_occupied(DestinationCell) and DestinationCell in get_walkable_cells(_units[inputUnit]) and id == _units[inputUnit].player):
		_move_unit.rpc(inputUnit,DestinationCell)
	else:
		print ("That isn't your unit!")
	pass

@rpc("authority", "call_local","reliable")
func _move_unit(inputUnit: Vector2i,new_cell: Vector2i) -> void:
	var unitToMove = _units[inputUnit]
	_units.erase(unitToMove.cell)
	_units[new_cell] = unitToMove
	unitToMove._set_is_walking(true)
	
	unitToMove.walk_along(map.getPath(new_cell,[unitToMove.cell]))
	
	await unitToMove.walk_finished
	# Finally, we clear the `_active_unit`, which also clears the `_walkable_cells` array.
	
@rpc("authority", "call_local","reliable")
func SpawnUnit(unitToSpawn: CharacterSheet):
	pass
	

func onCellSelected(cell):
	if not _active_unit:
		refresh_occupied()
		_select_unit(cell)
	elif _active_unit.is_selected:
		_move_unit_request.rpc(_active_unit.cell,cell)
		_deselect_active_unit()
		_clear_active_unit()
	pass # Replace with function body.


func _on_cursor_moved(new_cell):
	print(new_cell)
	pass


func debug_distance():
	if(debug):
		for x in tmRect.size.x:
			for y in tmRect.size.x:
				var sprite2d = RichTextLabel.new() # Create a new Sprite2D.
				sprite2d.position = Visualmap.map_to_local(Vector2(x,y))
				sprite2d.text = str(map.grid[x][y])
				add_child(sprite2d) # Add it as a child of this node.
				sprite2d.size = Vector2(40,40)
				
func exportTilemapToCsv():
	var file = FileAccess.open("user://Maps/saved_map.csv", FileAccess.WRITE)
	var data = Visualmap.get_used_cells()
	var string_array = PackedStringArray([])
	for x in (tmRect.size[tmRect.size.max_axis_index()]):
		string_array.clear()
		for y in (tmRect.size[tmRect.size.max_axis_index()]):
			if (data.has(Vector2i(x,y))):
				string_array.append("1")
			else:
				string_array.append("0")
		file.store_csv_line(string_array)
	file.close()
	
func loadCsvToTilemap():
	var dir = DirAccess.open("user://")
	dir.make_dir("Maps")
	var file
	if (Lobby.mapToLoad == ""):
		file = FileAccess.open("user://Maps/saved_map.csv", FileAccess.READ)
		print("Can't find it chief")
	else:
		file = FileAccess.open("user://Maps/" + Lobby.mapToLoad, FileAccess.READ)
	var grid: Array[Vector2i] = []
	var x: int = 0
	var y: int = 0
	while !file.eof_reached():
		x = 0
		for z in file.get_csv_line():
			if(z >= "1"):
				grid.append(Vector2i(int(x),y))
			if(z == "2"):
				_spawn_Points.append(Vector2i(int(x),y))
			x = x + 1
		y = y+1
	file.close()
	loadCordinatestoTileMap.rpc(grid,_spawn_Points)
	pass

@rpc("authority", "call_local","reliable")
func loadCordinatestoTileMap(input: Array[Vector2i],input2: Array[Vector2i]):
	Visualmap.set_cells_terrain_connect(input,0,0)
	_spawn_Points = input2
	MapLoaded.emit()
	tmRect = Visualmap.get_used_rect()
	map = Dmap.createSimple(tmRect.size[tmRect.size.max_axis_index()])
