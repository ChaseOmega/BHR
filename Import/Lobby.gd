extends Node

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

var Clients = {}
var playerinfo = {}
var mapToLoad: String = ""


func host_chat(Port, chatSize):
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(Port, chatSize)
	if error:
		return error
	print(Port)
	print(chatSize)
	multiplayer.multiplayer_peer = peer
	
func join_chat(IpAddress, Port):
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(IpAddress, Port)
	print(IpAddress);
	print(Port);
	if error:
		return error
	multiplayer.multiplayer_peer = peer

@rpc("any_peer","call_local","reliable")
func registerPlayer(input: Dictionary):
	if (multiplayer.get_unique_id() == 1):
		var infoToAdd: playerInfo = playerInfo.new()
		infoToAdd.userName = input.name
		infoToAdd.characterSheet.loadDictionary(input)
		playerinfo.get_or_add(multiplayer.get_remote_sender_id(),infoToAdd)
# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connect_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

	pass # Replace with function body.

@rpc("authority","call_local","reliable")
func startMatch():
	if (multiplayer.get_unique_id() == 1):
		get_tree().change_scene_to_file("res://Scenes/MatchHost_Refactor.tscn");
	else:
		get_tree().change_scene_to_file("res://Scenes/MatchClient_Refactor.tscn");

@rpc("authority","call_local","reliable")
func setMapToLoad(input:String):
	mapToLoad = input


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_player_connected(id):
	print(str("Player",id,"connected"))
	pass
func _on_player_disconnected(id):
	print(str("Player",id,"disconnected"))
	pass
func _on_connect_server():
	pass
func _on_connection_failed():
	pass
func _on_server_disconnected():
	pass
