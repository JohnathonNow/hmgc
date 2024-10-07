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
	fall(384)
	
func fall(dy):
	time = 0
	%Sprite2D.position.y -= dy
	starty = %Sprite2D.position.y
	
func _physics_process(delta):
	time += delta
	if time < .4:
		%Sprite2D.position.y = lerpf(starty, 0, time/.4)
	elif time < 0.7:
		%Sprite2D.position.y = sin(time * PI * 14) * 8
	else:
		%Sprite2D.position.y = 0
