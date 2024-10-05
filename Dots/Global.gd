extends Node
signal clicked(object)
signal undo(object)
signal restart(object)
var state = []

# Called when the node enters the scene tree for the first time.
func _ready():
	clicked.connect(onclick)
	undo.connect(doundo)
	restart.connect(dorestart)

func savestate(group="Balloons"):
	var frame = []
	for o in get_tree().get_nodes_in_group(group):
		frame += [{"position": o.position, "color": o.modulate}]
	state += [frame]
	
func loadstate(group="Balloons"):
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
	
func get_object_at(pos, group="Balloons"):
	for o in get_tree().get_nodes_in_group(group):
		if o.global_position.distance_to(pos) < 1:
			return o
	return null

func move_down_to(y=384, grid_size=64, group="Balloons"):
	print("poggers")
	var i = 0
	var objs = get_tree().get_nodes_in_group(group)
	while i < objs.size():
		var o = objs[i]
		print(o.global_position.y)
		if o.global_position.y < y and not get_object_at(o.global_position + Vector2(0, grid_size)):
			o.global_position.y += grid_size
			i = 0
		else:
			i += 1
	i = 0

func onclick(object):
	var x = {object: 1}
	var q = [object]
	while q:
		var i = q.pop_back()
		for p in [
			get_object_at(i.global_position + Vector2(64, 0)),
			get_object_at(i.global_position + Vector2(-64, 0)),
			get_object_at(i.global_position + Vector2(0, 64)),
			get_object_at(i.global_position + Vector2(0, -64)),
		]:
			if p and p not in x and p.modulate == object.modulate:
				x[p] = 1
				q.push_back(p)
	savestate()
	for k in x:
		k.free()
	call_deferred("move_down_to")

func dorestart():
	get_tree().reload_current_scene()
	state.clear()
	
func doundo():
	loadstate()
