extends "res://Scripts/PuzzleSingle.gd"

export var offset_goal: Vector3 = Vector3.ZERO
export var offset_margin: float = 0.05

func _ready():
	$PuzzlePrim.camera = camera
	$PuzzleSec.camera = camera

func validation():
	var offset = $PuzzleSec.t_offset - $PuzzlePrim.t_offset
#	print($PuzzlePrim.is_valid(), $PuzzleSec.is_valid())
	if $PuzzlePrim.is_valid() and $PuzzleSec.is_valid() and (offset_goal - offset).length() < offset_margin:
		$PuzzlePrim.solve(-offset_goal / 2)
		$PuzzlePrim.set_selected(false)
		$PuzzleSec.solve(offset_goal / 2)
		$PuzzleSec.set_selected(false)
		selected = null
		emit_signal("completed")

func _on_PuzzlePrim_moved():
	validation()


func _on_PuzzleSec_moved():
	validation()
