class_name Match_Visualization_Host
extends Match_Visualization

@export var UIBase: Control

func _on_cursor_moved(new_cell):
	pass
func _selectUnit(cell: Vector2i) -> bool:
	if (super(cell)):
		UIBase.show()
		return true
	return false

func _deselectActiveUnit() -> void:
	super()
	UIBase.hide()


func _drawCard():
	MatchServer.drawCardPlayer(_active_unit.player)


func _on_cursor_select_pressed(cell):
	pass # Replace with function body.
