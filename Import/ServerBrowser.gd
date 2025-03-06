extends Control

@export var IpAdress : LineEdit
@export var Port : SpinBox
const DEFAULT_SERVER_IP = "127.0.0.1"
@export var chat : PackedScene
@export var host : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	multiplayer.connection_failed.connect(_on_failed_connection)
	multiplayer.connected_to_server.connect(_on_connect_to_server)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_join_chatroom_button_pressed():
	if (IpAdress.text == null):
		Lobby.join_chat(DEFAULT_SERVER_IP,Port.value);
	else:
		Lobby.join_chat(IpAdress.text,Port.value);
	get_tree().change_scene_to_packed(chat);

func _on_create_chatroom_button_pressed():
	Lobby.host_chat(Port.value,10);
	get_tree().change_scene_to_packed(host);

func _on_failed_connection():
	print("Connection_Failed_Server");
	
func _on_connect_to_server():
	print("Connection_Success_Server");
