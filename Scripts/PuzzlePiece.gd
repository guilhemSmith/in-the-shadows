tool
extends Spatial

signal moved

export var mesh: Resource = null setget set_mesh

var rot_basis: Basis = Basis(Quat.IDENTITY)
export var rot_margin: float = 0.002

export var euler_start: Vector3 = Vector3(0, 0, 0) setget set_euler_start
export var euler_goal: Vector3 = Vector3(0, 0, 0)
export var euler_goal2: Vector3 = Vector3(0, 0, 0)
onready var quat_goal : Quat = Quat(euler_goal)
onready var quat_goal2 : Quat = Quat(euler_goal2)

export var enable_horizontal: bool = true
export var h_scale: float = 0.002

export var enable_vertical: bool = true
export var v_scale: float = 0.05

export var enable_translations: bool = true
export var t_offset: Vector3 = Vector3.ZERO setget set_t_offset
export var t_scale: float = 0.025
export var t_limit_x: float = 1.5
export var t_limit_y: float = 1.0

export var selected: bool = false setget set_selected
var rotating: bool = false
var rotating_alt: bool = false
var translating: bool = false

export var validation_delay: float = 1.0

onready var model = $Model setget set_model
var camera: Camera

func _ready():
	print(euler_start)
	if mesh != null:
		model.set_mesh(mesh)
		if not Engine.editor_hint:
			model.create_convex_collision()
	set_selected(selected)
	
	transform.origin = t_offset
	rot_basis = Basis(Quat(euler_start).normalized())
	model.transform.basis = rot_basis

func _process(delta):
	if Engine.editor_hint:
		return

	if enable_translations:
		transform.origin = lerp(transform.origin, t_offset, delta * 10)

	if enable_horizontal or enable_vertical:
		model.transform.basis = Basis(model.transform.basis.get_rotation_quat().slerp(rot_basis.get_rotation_quat(), delta * 10))

func _input(event):
	if Engine.editor_hint:
		return

	if selected:
		if event.is_action_pressed("dev_debug"):
			print(rot_basis.get_rotation_quat().get_euler())
		if event is InputEventMouseButton and event.get_button_index() == 1:
			if not event.is_pressed() and (rotating or rotating_alt or translating):
				emit_signal("moved")
			if Input.is_action_pressed("piece_alt_rot"):
				rotating = false
				rotating_alt = event.is_pressed() and enable_vertical
				translating = false
			elif Input.is_action_pressed("piece_trans"):
				rotating = false
				rotating_alt = false
				translating = event.is_pressed() and enable_translations
			else:
				rotating = event.is_pressed() and enable_horizontal
				rotating_alt = false
				translating = false
		if event is InputEventMouseMotion:
			if rotating:
				rot_basis = rot_basis.rotated(Vector3.UP, event.relative.x * h_scale)
			if rotating_alt and camera != null:
#				var obj_pos = camera.unproject_position(global_transform.origin)
				var obj_pos = get_tree().root.size / 2
				var click_from_pos = (obj_pos - event.position).normalized()
				var v_offset = -click_from_pos.cross(event.relative.normalized())
				rot_basis = rot_basis.rotated(Vector3.FORWARD, v_offset * v_scale)
			if translating:
				var trans = Vector3(event.relative.x, -event.relative.y, 0).normalized() * t_scale
				t_offset.x = clamp(t_offset.x + trans.x, -t_limit_x, t_limit_x)
				t_offset.y = clamp(t_offset.y + trans.y, -t_limit_y, t_limit_y)

func set_selected(select: bool):
	selected = select
	var mod = get_node("Model")
	if mod != null:
		if selected:
			var material = SpatialMaterial.new()
			material.albedo_color = Color.red
			mod.material_override = material
		else:
			var material = SpatialMaterial.new()
			material.albedo_color = Color.blue
			mod.material_override = material

func solve(offset = null):
	if offset != null:
		t_offset = offset
	var current_quat = rot_basis.get_rotation_quat()
	if (current_quat - quat_goal).length_squared() < (current_quat - quat_goal2).length_squared():
		rot_basis = Basis(quat_goal)
	else:
		rot_basis = Basis(quat_goal2)

func is_valid():
	var current_quat = rot_basis.get_rotation_quat()
	return (
		(current_quat - quat_goal).length_squared() < rot_margin
		or (current_quat - quat_goal2).length_squared() < rot_margin
	)

func set_mesh(new_mesh):
	mesh = new_mesh
	if model != null:
		model.set_mesh(mesh)

func set_model(new_model):
	model = new_model
	model.transform.basis = rot_basis
	if mesh != null:
		model.set_mesh(mesh)

func set_euler_start(new_euler):
	euler_start = new_euler
	rot_basis = Basis(Quat(euler_start).normalized())
	if model != null:
		model.transform.basis = rot_basis

func set_t_offset(new_offset):
	t_offset = new_offset
	transform.origin = t_offset
