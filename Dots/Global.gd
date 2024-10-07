extends Node2D
signal clicked(object)
signal undo(object)
signal restart(object)
var state = []
var combo = []
var lastOver = null
var isSquare = false
var moves = 30
var score = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	undo.connect(doundo)
	restart.connect(dorestart)	
	updateLine()
	fill()

func savestate(group="Dots"):
	var frame = []
	for o in get_tree().get_nodes_in_group(group):
		frame += [{"position": o.position, "color": o.modulate}]
	state += [frame]
	
func loadstate(group="Dots"):
	var frame = state.pop_back()
	if not frame:
		return
	for o in get_tree().get_nodes_in_group(group):
		o.free()
	for obj in frame:
		var x = preload("res://Dots/dot.tscn").instantiate()
		get_tree().current_scene.get_node("%Dots").add_child(x)
		x.position = obj["position"]
		x.modulate = obj["color"]
	
func get_object_at(pos, group="Dots"):
	for o in get_tree().get_nodes_in_group(group):
		if o.global_position.distance_to(pos) < 48:
			return o
	return null

func move_down_to(fy=384, grid_size=64, group="Dots"):
	var i = 0
	var objs = get_tree().get_nodes_in_group(group)
	while i < objs.size():
		var o = objs[i]
		if o.global_position.y < fy and not get_object_at(o.global_position + Vector2(0, grid_size)):
			o.global_position.y += grid_size
			o.fall(grid_size)
			i = 0
		else:
			i += 1
	fill()
	
func fill():
	for x in range(96, 416 + 1, 64):
		for y in range(64, 384 + 1, 64):
			var v = Vector2(x, y)
			if not get_object_at(v):
				var p = preload("res://Dots/dot.tscn").instantiate()
				get_tree().current_scene.get_node("%Dots").add_child(p)
				p.position = v


func dorestart():
	get_tree().reload_current_scene()
	state.clear()
	score = 0
	moves = 30
	
func doundo():
	loadstate()
	
func updateLine():
	%Line.clear_points()
	for n in combo:
		%Line.add_point(n.global_position)
		%Line.modulate = n.modulate
		
func kill():
	if len(combo) > 1:
			savestate()
			moves -= 1
			for k in combo:
				score += 1
				k.free()
	combo = []
	call_deferred("move_down_to")
	updateLine()

func square():
	if not combo:
		return
	moves -= 1
	var x = combo[-1].modulate
	for o in get_tree().get_nodes_in_group("Dots"):
		if o.modulate == x:
			score += 1
			o.free()
	combo = []
	call_deferred("move_down_to")
	updateLine()

func _physics_process(_delta):
	%StatusMoves.text = "[right]%s[/right]" % moves
	%StatusScore.text = "%s" % score
	if not moves:
		return
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var x = get_object_at(%SubViewportContainer.get_local_mouse_position())
		if x == lastOver or isSquare:
			return
		if combo and x and is_instance_of(x, Dot):
			var hor = abs(x.global_position.y - combo[-1].global_position.y) < 1 and abs(x.global_position.x - combo[-1].global_position.x) < 65
			var ver = abs(x.global_position.x - combo[-1].global_position.x) < 1 and abs(x.global_position.y - combo[-1].global_position.y) < 65
			var isok = x.modulate == combo[0].modulate and (hor or ver)
			if x in combo:
				var index = combo.find(x)
				if index == 0 and len(combo) >= 4 and isok:
					isSquare = true
					combo.push_back(x)
					updateLine()
				else:
					combo.resize(index + 1)
					#if index == len(combo) - 1:
						#combo.pop_back()
					updateLine()
			else:
				if isok:
					combo.push_back(x)
					updateLine()
		elif x and not combo:
			combo.push_back(x)
		lastOver = x
	elif combo:
		if isSquare:
			square()
		else:
			kill()
		isSquare = false
		combo = []
