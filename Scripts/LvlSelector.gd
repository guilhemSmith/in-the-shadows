extends Spatial

onready var camera = get_tree().root.get_camera()

var selected_cube = null
onready var offset = Vector3.ZERO
onready var base_offset = transform.origin
var enabled = false

func _process(delta):
	transform.origin = lerp(transform.origin, offset + base_offset, delta * 5)

func lvl_selected():
	if selected_cube != null:
		return selected_cube.lvl
	else:
		return 0

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
				if selected_cube != null:
					selected_cube.select(false)
				hit.select(true)
				selected_cube = hit
				offset = - selected_cube.transform.origin * scale
