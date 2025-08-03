class_name Dot extends Node2D

const COLORS = [
	Color.RED,
	Color.BLUE,
	Color.YELLOW,
	Color.GREEN
]

var time = 0
var starty = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	self.modulate = COLORS.pick_random()

func _physics_process(delta):
	time += delta
	position.y += 1.1*delta
