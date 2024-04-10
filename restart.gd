extends Control

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed() and get_local_mouse_position().length() < 64:
			Global.restart.emit()
			return false
	return true
