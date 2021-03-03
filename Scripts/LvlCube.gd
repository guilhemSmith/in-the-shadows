tool
extends StaticBody

var selected = false setget select
export var unlocked = true setget unlock
export var lvl = 1

const COLOR_LOCKED: Color = Color.black
const COLOR_SELECT: Color = Color.red
const COLOR_IDLE: Color = Color.blue


func _ready():
	self.select(selected)
	if Engine.editor_hint:
		return
	if lvl < 2:
		$Link.queue_free()
	elif not unlocked:
		var material = SpatialMaterial.new()
		material.albedo_color = COLOR_LOCKED
		$Link.material_override = material
		$MeshInstance.material_override = material

func unlock(val: bool):
	unlocked = val
	if has_node("Link"):
		var link_mat = SpatialMaterial.new()
		if not unlocked:
			link_mat.albedo_color = COLOR_LOCKED
		else:
			link_mat.albedo_color = COLOR_IDLE
		$Link.material_override = link_mat
		
	var cube_mat = SpatialMaterial.new()
	if not unlocked:
		cube_mat.albedo_color = COLOR_LOCKED
	elif not selected:
		cube_mat.albedo_color = COLOR_IDLE
	else:
		cube_mat.albedo_color = COLOR_SELECT
	$MeshInstance.material_override = cube_mat

func select(val: bool):
	if unlocked:
		selected = val
		var material = SpatialMaterial.new()
		if (selected):
			material.albedo_color = COLOR_SELECT
		else:
			material.albedo_color = COLOR_IDLE
		$MeshInstance.material_override = material
