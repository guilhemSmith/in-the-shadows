extends Spatial

func _ready():
	pass

func _on_PuzzlePiece_rotation_valid():
	$PuzzlePiece.solve()
	$PuzzlePiece.select(false)
	print("bravo")
