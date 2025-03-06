extends Control

signal incoming_message(message)
@export var ChatDisplay : RichTextLabel
@export var MessageInput : LineEdit


# Called when the node enters the scene tree for the first time.
func _ready():
	incoming_message.connect(updateLog)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func sendMessage():
	send_message.rpc(MessageInput.text);
	pass
	
func updateLog(message):
	print("LogUpdated");
	ChatDisplay.add_text(message)
	pass
	
@rpc("any_peer","call_local")
func send_message(message):
	print("Sending a Message")
	incoming_message.emit(message)
	pass
