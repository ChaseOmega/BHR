extends Button
class_name DoubleButton

signal primaryPressed
signal secondaryPressed

func _gui_input(event:InputEvent):
	if(event is InputEventMouseButton):
		if(event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
			primaryPressed.emit()
		
		if(event.button_index == MOUSE_BUTTON_RIGHT and event.pressed):
			secondaryPressed.emit()
