class_name Dot extends Node2D

const COLORS = [
	Color.RED,
	Color.BLUE,
	Color.YELLOW,
	Color.GREEN
]

# Called when the node enters the scene tree for the first time.
func _ready():
	self.modulate = COLORS.pick_random()
	pass # Replace with function body.

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed() and get_local_mouse_position().length() < 16:
			get_tree().root.get_child(0).get_node("Global").clicked.emit(self)
			return false
	return true
