extends Spatial

onready var camera = get_tree().root.get_camera()

onready var selected_cube = get_child(0)
onready var offset = Vector3.ZERO
onready var base_offset = transform.origin
var enabled = false setget enable

signal new_title(title)

func _ready():
	selected_cube.select(true)

func _process(delta):
	transform.origin = lerp(transform.origin, offset + base_offset, delta * 5)

func get_title():
	return selected_cube.lvl_title

func lvl_selected():
	if selected_cube != null:
		return selected_cube.lvl
	else:
		return 0

func enable(val):
	enabled = val
	offset = Vector3.ZERO
	if selected_cube != null:
		selected_cube.select(false)
		selected_cube = get_child(0)
		selected_cube.select(true)
		emit_signal("new_title", get_title())

func unlock_lvl(lvl):
	for cube in get_children():
		cube.unlocked = cube.lvl <= lvl

func _input(event):
	if enabled and event is InputEventMouseButton and event.get_button_index() == 1:
		var mouse_pos = event.position
		var ray_from = camera.project_ray_origin(mouse_pos)
		var ray_to = ray_from + camera.project_ray_normal(mouse_pos) * 100
		var space_state = get_world().direct_space_state
		var selection = space_state.intersect_ray(ray_from, ray_to)
		if selection.size() > 0:
			var hit = selection["collider"]
			if hit.unlocked and hit != selected_cube:
				selected_cube.select(false)
				hit.select(true)
				selected_cube = hit
				offset = - selected_cube.transform.origin * scale
				emit_signal("new_title", get_title())
	elif enabled and event is InputEventKey:
		var next_cube = null
		if Input.is_action_just_pressed("ui_left"):
			next_cube = get_child(clamp(selected_cube.lvl - 2, 0, 3))
		elif Input.is_action_just_pressed("ui_right"):
			next_cube = get_child(clamp(selected_cube.lvl, 0, 3))
		if next_cube != null and next_cube != selected_cube and next_cube.unlocked:
			selected_cube.select(false)
			next_cube.select(true)
			selected_cube = next_cube
			offset = - selected_cube.transform.origin * scale
			emit_signal("new_title", get_title())
			
