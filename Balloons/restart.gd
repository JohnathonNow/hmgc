extends Control

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed() and get_local_mouse_position().length() < 32:
			get_tree().root.get_child(0).get_node("Global").restart.emit()
			return false
	return true
