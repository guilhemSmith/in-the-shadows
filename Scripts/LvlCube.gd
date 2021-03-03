tool
extends StaticBody

var selected = false setget select
export var unlocked = true setget unlock
export var lvl = 1

func _ready():
	self.select(selected)
	if Engine.editor_hint:
		return
	if lvl < 2:
		$Link.queue_free()
	elif not unlocked:
		var material = SpatialMaterial.new()
		material.albedo_color = Color.darkgray
		$Link.material_override = material
		$MeshInstance.material_override = material

func unlock(val: bool):
	unlocked = val
	var material = SpatialMaterial.new()
	if not unlocked:
		material.albedo_color = Color.darkgray
	if has_node("Link"):
		$Link.material_override = material
	$MeshInstance.material_override = material
	self.select(selected)

func select(val: bool):
	if unlocked:
		selected = val
		var material = SpatialMaterial.new()
		if (selected):
			material.albedo_color = Color.red
		else:
			material.albedo_color = Color.blue
		$MeshInstance.material_override = material
