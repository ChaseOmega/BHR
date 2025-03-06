extends Control


@export var mapSelect: OptionButton
@export var Mapsettings: Array[OptionButton]
@export var mapInfoSize: Vector2i = Vector2i.ZERO
@export var mapInfoPlayer: int
@export var mapInfoEquipment: int:
	set(value):
		mapInfoEquipment = value
		EquipmentListUI.maxSelected = value
		EquipmentListUI.clear()
@export var mapInfoMonster: int
@export var mapInfoSizeLabel: Label
@export var mapInfoPlayerLabel: Label
@export var mapInfoEquipmentLabel: Label
@export var mapInfoMonsterLabel: Label
@export var events: Array[OptionButton]
@export var conditions: Array[OptionButton]
@export var cardsToSubmit: Array[int] = []
@export var equipmentToSubmit: Array[int] = []
@export var effectVisualizerBase: PackedScene
@export var CardListUI: SelecterController
@export var EquipmentListUI: SelecterController



func _ready():
	loadMaps()
	loadCards()
	loadEquipment()
	updateMapInfo()
	mapSelect.selected = -1
	pass # Replace with function body.
	
func loadMaps():
	var dir = DirAccess.open("user://")
	dir.make_dir("Maps")
	dir.change_dir("user://Maps")
	var maps = dir.get_files()
	for x in maps:
		mapSelect.add_item(x)

func loadCards():
	CardListUI.loadOptions(Manifest.cards)

func submitCards():
	for x in CardListUI.optionsSelected:
		cardsToSubmit.append(Manifest.cards.find(x))
	pass

func loadEquipment():
	EquipmentListUI.loadOptions(Manifest.equipment)

func submitEquipment():
	for x in EquipmentListUI.optionsSelected:
		equipmentToSubmit.append(Manifest.equipment.find(x))
	pass

func startMatch():
	print("Level Transition")
	submitCards()
	submitEquipment()
	Lobby.setMapToLoad(mapSelect.get_item_text(mapSelect.selected))
	MatchServer._addCardArrayToDeck(cardsToSubmit,multiplayer.get_unique_id())
	MatchServer._addEquipmentArrayToMap(equipmentToSubmit, multiplayer.get_unique_id())
	MatchServer.startMatch()
	Lobby.startMatch.rpc()
	pass


func loadMapInfo(maptoLoad: String):
	mapInfoSize = Vector2i.ZERO
	mapInfoEquipment = 0
	mapInfoPlayer = 0
	mapInfoMonster = 0
	var dir = DirAccess.open("user://")
	dir.make_dir("Maps")
	var file
	if (maptoLoad == ""):
		file = FileAccess.open("user://Maps/saved_map.csv", FileAccess.READ)
		print("Can't find it chief")
	else:
		file = FileAccess.open("user://Maps/" + maptoLoad, FileAccess.READ)
	var x: int = 0
	var maxX: int = 0
	var y: int = 0
	while !file.eof_reached():
		if x > maxX:
			maxX = x
		x = 0
		for z in file.get_csv_line():
			if(z == "2"):
				mapInfoPlayer = mapInfoPlayer + 1
			if(z == "3"):
				mapInfoMonster = mapInfoMonster + 1
			if(z == "4"):
				mapInfoEquipment = mapInfoEquipment + 1
			x = x + 1
		y = y+1
	file.close()
	mapInfoSize = Vector2i(maxX,y)
	pass

func updateMapInfo():
	mapInfoPlayerLabel.text = "Player Slots Available: " + str(mapInfoPlayer)
	mapInfoEquipmentLabel.text = "Equipment Slots Available: " + str(mapInfoEquipment)
	mapInfoMonsterLabel.text = "Monster Spawners: " + str(mapInfoEquipment)
	mapInfoSizeLabel.text = "Map Size: " + str(mapInfoSize.x) + " by " + str(mapInfoSize.y)
	pass

func _on_map_selection_item_selected(index):
	loadMapInfo(mapSelect.get_item_text(mapSelect.selected))
	updateMapInfo()
	pass # Replace with function body.
