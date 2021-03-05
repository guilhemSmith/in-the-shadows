extends Spatial

signal completed
signal start_tuto(name)
signal stop_tuto

export var tuto_goal = 0
export var tuto_current = 0

var selected = null
var active = true
onready var camera: Camera = get_parent().find_node("Camera")

func _ready():
	if get_node_or_null("PuzzlePiece") != null:
		$PuzzlePiece.camera = camera
	$AnimationPlayer.play("LevelAnimationStart")
	if tuto_goal >= 1 and tuto_current == 0:
		$Timer.start(3)

func _input(event):
	if active and event is InputEventMouseButton:
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
					elif tuto_goal >= 1 and tuto_current == 0:
						if not $Timer.is_stopped():
							$Timer.stop()
						emit_signal("stop_tuto", 1)
						tuto_current = 1
					if tuto_goal >= 2 and tuto_current < tuto_goal:
						$Timer.start(1)
					selected = hit

func move_away():
	active = false
	$AnimationPlayer.play("LevelAnimationNext")

func _on_PuzzlePiece_moved():
	if active and $PuzzlePiece.is_valid():
		$PuzzlePiece.solve()
		$PuzzlePiece.set_selected(false)
		selected = null
		emit_signal("completed")
		if not $Timer.is_stopped():
			$Timer.stop()
			emit_signal("stop_tuto", tuto_current + 1)

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Next":
		queue_free()


func _on_Timer_timeout():
	match tuto_current:
		0:
			emit_signal("start_tuto", "SelectionClick")
		1:
			emit_signal("start_tuto", "FirstRotation")
		2:
			emit_signal("start_tuto", "SecondRotation")
		3:
			emit_signal("start_tuto", "Translation")
		


func _on_PuzzlePiece_started_first_rot():
	if tuto_goal >= 2 and tuto_current == 1:
		if not $Timer.is_stopped():
			$Timer.stop()
		emit_signal("stop_tuto", 2)
		tuto_current = 2


func _on_PuzzlePiece_started_second_rot():
	if tuto_goal >= 3 and tuto_current == 2:
		if not $Timer.is_stopped():
			$Timer.stop()
		emit_signal("stop_tuto", 3)
		tuto_current = 3


func _on_PuzzlePiece_started_trans():
	if tuto_goal >= 4 and tuto_current == 3:
		if not $Timer.is_stopped():
			$Timer.stop()
		emit_signal("stop_tuto", 4)
		tuto_current = 4
