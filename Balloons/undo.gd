extends Control

func _on_button_pressed():
	%Global.undo.emit()
