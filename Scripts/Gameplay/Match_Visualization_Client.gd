class_name Match_Visualization_Client
extends Match_Visualization

enum UIMode {ModeNeutral, ModeCard, ModeMove, ModeAttack, ModeInteract,ModeSkill,ModeEquipment,ModeObserve,ModeTargetCell,ModeTargetPlayer}
@export var ModeUI: Control
@export var MoveUI: Control
@export var CardUI: Control
@export var AttackUI: Control
@export var InteractUI: Control
@export var SkillUI: Control
@export var EquipmentUI: Control
@export var ObserveUI: Control

var cInterface: cardInterface
var sInterface: skillInterface
var eInterface: equipmentInterface
@export var effecterVisualizer: EffecterVisualizer
var CurrentMode: int = UIMode.ModeNeutral
var numberOfTargets: int = 0
var targetCells: Array[Vector2i] = []
var targetPlayers: Array[int] = []
var targetOptions: Array = []

func _initialize() -> void:
	super()
	cInterface = cardInterfaceBase.instantiate()
	cInterface.setup(MatchServer.players[multiplayer.get_unique_id()])
	sInterface = skillInterfaceBase.instantiate()
	sInterface.setup(MatchServer.players[multiplayer.get_unique_id()])
	eInterface = equipmentInterfaceBase.instantiate()
	eInterface.setup(MatchServer.players[multiplayer.get_unique_id()])
	SignalManager.requestPlayerInputCell.connect(_onRequestForPlayerInputCell)
	SignalManager.requestDisplayInfo.connect(_onDisplayInfo)
	CardUI.add_child(cInterface)
	SkillUI.add_child(sInterface)
	EquipmentUI.add_child(eInterface)

func _selectUnit(cell: Vector2i) -> bool:
	# Here's some optional defensive code: we return early from the function if the unit's not
	# registered in the `cell`.
	if (super(cell)):
		cInterface.unit = MatchServer.board._units[cell]
		sInterface.unit = MatchServer.board._units[cell]
		eInterface.unit = MatchServer.board._units[cell]
		_modeMenu()
		return true
	return false
	
func _modeMenu():
	ModeUI.show()
	pass

func _modeMove():
	print("Moving")
	_ResetMode()
	MatchServer.moveUnitPrep(_active_unit.cell)
	pass
func _modeAttack():
	print("Attacking")
	_ResetMode()
	CurrentMode = UIMode.ModeAttack
	AttackUI.show()
	pass
func _modeCard():
	print("PokerTime")
	_ResetMode()
	CurrentMode = UIMode.ModeCard
	CardUI.show()
	pass
func _modeInteract():
	print("Interacting")
	_ResetMode()
	CurrentMode = UIMode.ModeInteract
	InteractUI.show()
	pass
func _modeSkill():
	print("Skilling")
	_ResetMode()
	CurrentMode = UIMode.ModeSkill
	SkillUI.show()
	pass
func _modeEquipment():
	print("Equiping")
	_ResetMode()
	CurrentMode = UIMode.ModeEquipment
	EquipmentUI.show()
	pass
func _modeObserve():
	print("Observing")
	_ResetMode()
	CurrentMode = UIMode.ModeObserve
	ObserveUI.show()
	pass
func _modeTargetCell():
	print("TargetingCells")
	ModeUI.hide()
	CurrentMode = UIMode.ModeTargetCell
	pass
func _modeTargetPlayer():
	print("Observing")
	ModeUI.hide()
	CurrentMode = UIMode.ModeTargetPlayer
	pass
func _modeDefault():
	CurrentMode = UIMode.ModeNeutral
	print("Returning To Neutral")
	_ResetMode()
	pass

func _ResetMode():
	MoveUI.hide()
	CardUI.hide()
	AttackUI.hide()
	InteractUI.hide()
	SkillUI.hide()
	EquipmentUI.hide()
	ObserveUI.hide()
	_unit_overlay.clear()
	targetCells.clear()
	targetPlayers.clear()
	numberOfTargets = 0
	var returnVector2Array: Array[Vector2i] = []
	SignalManager.responsePlayerInputCell.emit(returnVector2Array)
	SignalManager.responsePlayerInputPlayer.emit([])
	CurrentMode = UIMode.ModeNeutral
	
func _ResetUI():
	_ResetMode()
	ModeUI.hide()
	_deselectActiveUnit()
	
func onCellSelected(cell):
	super(cell)
	if (CurrentMode == UIMode.ModeTargetCell):
		if (targetOptions.has(Vector2i(cell))):
			targetCells.append(Vector2i(cell))
		if (targetCells.size() == numberOfTargets):
			SignalManager.responsePlayerInputCell.emit(targetCells)
			CurrentMode = UIMode.ModeNeutral
			_ResetUI()
	if (CurrentMode == UIMode.ModeTargetPlayer):
		if (targetCells.size() == numberOfTargets):
			MatchServer.responsePlayerInputPlayer.emit(targetPlayers)
			CurrentMode = UIMode.ModeNeutral
			_ResetUI()
	pass # Replace with function body.
func _on_cursor_select_pressed(cell):
	print("Trying to reset")
	_ResetUI()
	pass # Replace with function body.

func _move_avatar(inputUnit: Server_Unit,inputPath: PackedVector2Array) -> void:
	var avatarToMove = _avatars[inputUnit]
	avatarToMove._set_is_walking(true)
	avatarToMove.walk_along(inputPath)
	# Finally, we clear the `_active_unit`, which also clears the `_walkable_cells` array.

func _on_cursor_moved(new_cell):
	super(new_cell)
	pass

func _onRequestForPlayerInputCell(options: Array[Vector2i], numberRequested: int):
	numberOfTargets = numberRequested
	targetOptions = options
	_modeTargetCell()
	_unit_overlay.draw(options)
	pass

func _onDisplayInfo(effecterToDisplay: displayable):
	effecterVisualizer.effecter = effecterToDisplay
	effecterVisualizer.showDisplay()
	pass

func _onRequestForPlayerInputPlayer(options: Array[int], numberRequested: int):
	numberOfTargets = numberRequested
	_modeTargetPlayer()
	pass
