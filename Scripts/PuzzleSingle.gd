extends Spatial

signal completed

export var lvl_unlock: int = 0
var selected = null
onready var camera: Camera = get_parent().find_node("Camera")

func _ready():
	if $PuzzlePiece != null:
		$PuzzlePiece.camera = camera

func _input(event):
	if event is InputEventMouseButton:
		if event.get_button_index() == 1 and event.is_pressed():
			var mouse_pos = event.position
			var ray_from = camera.project_ray_origin(mouse_pos)
			var ray_to = ray_from + camera.project_ray_normal(mouse_pos) * 10
			var space_state = get_world().direct_space_state
			var selection = space_state.intersect_ray(ray_from, ray_to)
			if selection.size() > 0:
				var hit = selection["collider"].get_parent().get_parent()
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
		emit_signal("completed")
