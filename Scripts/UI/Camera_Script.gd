extends Camera2D

var input: Input
@export var moveSpeed: int = 1
func _process(delta: float) -> void:
	position += Input.get_vector("Alternative_Left", "Alternative_Right", "Alternative_Up", "Alternative_Down") * delta * moveSpeed;
