extends Node2D

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed() and get_local_mouse_position().length() < 48:
			Global.undo.emit()
			return false
	return true
