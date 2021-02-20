tool
extends CSGMesh

func _ready():
	if Engine.editor_hint:
		var new_mesh = get_parent().mesh
		if new_mesh != null:
			set_mesh(new_mesh)
