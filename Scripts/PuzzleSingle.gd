extends Spatial

var selected = null

func _ready():
	pass

func _input(event):
	if event is InputEventMouseButton:
		if event.get_button_index() == 1 and event.is_pressed():
			var mouse_pos = event.position
			var ray_from = $Camera.project_ray_origin(mouse_pos)
			var ray_to = ray_from + $Camera.project_ray_normal(mouse_pos) * 10
			var space_state = get_world().direct_space_state
			var selection = space_state.intersect_ray(ray_from, ray_to)
			if selection.size() > 0:
				var hit = selection["collider"]
				if not hit.selected:
					hit.set_selected(true)
					if selected != null:
						selected.set_selected(false)
					selected = hit
					return

func _on_PuzzlePiece_moved():
	if $PuzzlePiece.is_valid():
		$PuzzlePiece.solve()
		$PuzzlePiece.set_selected(false)
		selected = null
		print("bravo")
