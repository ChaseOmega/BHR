class_name Match_Visualization
extends Node2D

const ManhattanDirections = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
const DiagonalDirections = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN,Vector2i.LEFT+Vector2i.UP,Vector2i.LEFT+Vector2i.DOWN,Vector2i.RIGHT + Vector2i.UP, Vector2i.RIGHT + Vector2i.DOWN]
var DirectionsType = ManhattanDirections

var debug = true
@export var _avatars := {}
@export var avatarBase: PackedScene
var _active_unit: avatar
@export var playervisual: Texture2D

@export var playerInfoDisplayHolder: GridContainer
@export var playerInfoDisplayBase: PackedScene
@export var cardInterfaceBase: PackedScene
@export var skillInterfaceBase: PackedScene
@export var equipmentInterfaceBase: PackedScene

@onready var _unit_overlay: UnitOverlay = $UnitOverlay
@onready var Visualmap: TileMapLayer = $TileMapLayer

@onready var debugdisplays: Array[RichTextLabel] = []

@export var targetRequest: Array = []
func _ready() -> void:
	loadCordinatestoTileMap()
	_initialize()
	SignalManager.UnitMoved.connect(_moveAvatar)
	SignalManager.UnitTeleported.connect(_teleportAvatar)
	SignalManager.highlightCells.connect(cellDebug)
	SignalManager.selectCell.connect(onCellSelected)

func cellDebug(input:Array[Vector2i]):
	_unit_overlay.draw(input)

func _initialize() -> void:
	for u in MatchServer.board._units:
		var created_avatar: avatar = avatarBase.instantiate()
		add_child(created_avatar)
		created_avatar.cell = u
		created_avatar.player = MatchServer.board._units[u].player
		#Remove this later. its just for testing so that I don't have to click around as much between client versions.
		if (created_avatar.player == multiplayer.get_unique_id()):
			created_avatar._sprite.texture = playervisual
		created_avatar.position = Visualmap.map_to_local(u)
		_avatars[MatchServer.board._units[u]] = created_avatar
	for p in MatchServer.players:
		var player_visualizer: Match_Visualization_Player = playerInfoDisplayBase.instantiate()
		player_visualizer.setup(MatchServer.players[p])
		playerInfoDisplayHolder.add_child(player_visualizer)

func _selectUnit(cell: Vector2i) -> bool:
	# Here's some optional defensive code: we return early from the function if the unit's not
	# registered in the `cell`.
	if not MatchServer.board._units.has(cell):
		return false
	_active_unit = _avatars[MatchServer.board._units[cell]]
	
	_active_unit.set_is_selected(true)
	debugDistance()
	return true

func _deselectActiveUnit() -> void:
	if (_active_unit != null):
		_active_unit.is_selected = false
		_active_unit = null

func getWalkableCells(unit: Server_Unit) -> Array[Vector2i]:
	var targets := [unit.cell]
	return MatchServer.board.getCellsUnderDistance(unit.move_range,targets)
	
func onCellSelected(cell):
	if not _active_unit:
		_selectUnit(cell)
	pass # Replace with function body.

func _moveAvatar(inputUnit: Server_Unit,inputPath: PackedVector2Array) -> void:
	var avatarToMove:avatar = _avatars[inputUnit]
	avatarToMove._set_is_walking(true)
	avatarToMove.walk_along(inputPath)
	# Finally, we clear the `_active_unit`, which also clears the `_walkable_cells` array.
func _teleportAvatar(inputUnit: Server_Unit,destination: Vector2i) -> void:
	var avatarToMove:avatar = _avatars[inputUnit]
	avatarToMove.set_pos(destination)
	# Finally, we clear the `_active_unit`, which also clears the `_walkable_cells` array.


func _on_cursor_moved(new_cell):
	pass
	
func loadCordinatestoTileMap():
	var input: Array[Vector2i] = MatchServer.board.getGameBoardAsVector2iArray()
	Visualmap.set_cells_terrain_connect(input,0,0)

func debugDistance():
	MatchServer.board.calculateDmap([_active_unit.cell])
	if(debug):
		for x in debugdisplays:
			x.free()
		
		debugdisplays.clear()
		for x in MatchServer.board.size:
			for y in MatchServer.board.size:
				var sprite2d = RichTextLabel.new() # Create a new Sprite2D.
				sprite2d.position = Visualmap.map_to_local(Vector2(x,y))
				sprite2d.text = str(MatchServer.board.dGrid[x][y])
				add_child(sprite2d) # Add it as a child of this node.
				sprite2d.size = Vector2(40,40)
				debugdisplays.append(sprite2d)
