extends Spatial

signal rotation_valid

export var mesh: Resource = null

var rot_basis: Basis = Basis(Quat.IDENTITY)
export var rot_goal: Basis = Basis(Quat.IDENTITY)
export var rot_start: Basis = Basis(Quat.IDENTITY)
export var rot_margin: float = 0.25

export var enable_horizontal: bool = true
export var h_scale: float = 0.01

export var enable_vertical: bool = true
export var v_scale: float = 0.01

export var enable_translations: bool = true
export var t_offset: Vector3 = Vector3.ZERO
export var t_scale: float = 0.05
export var t_limit_x: float = 1.5
export var t_limit_y: float = 1.0

var selected: bool = true
var rotating: bool = false
var translating: bool = false

export var validation_delay: float = 1.0

onready var timer_validation: Timer = $Timer
onready var model = $Model

func _ready():
	if model != null:
		model.set_mesh(mesh)

	rot_goal = rot_goal
	rot_start = rot_start
	rot_basis = rot_start
	model.transform.basis = rot_basis

func _process(delta):
	if enable_translations:
		transform.origin = lerp(transform.origin, t_offset, delta * 10)

	if enable_horizontal or enable_vertical:
			model.transform.basis = Basis(model.transform.basis.get_rotation_quat().slerp(rot_basis.get_rotation_quat(), delta * 10))

func _input(event):
	if selected:
		if event is InputEventMouseButton and event.get_button_index() == 1:
			if Input.is_action_pressed("player_ctrl"):
				rotating = false
				translating = event.is_pressed() and enable_translations
			else:
				rotating = event.is_pressed()
				translating = false
		if event is InputEventMouseMotion:
			if rotating:
				if enable_horizontal:
					rot_basis = rot_basis.rotated(Vector3.UP, event.relative.x * h_scale)
				if enable_vertical:
					rot_basis = rot_basis.rotated(Vector3.FORWARD, event.relative.y * v_scale)
				if timer_validation.is_stopped() and is_valid():
					timer_validation.start(validation_delay)
				elif not timer_validation.is_stopped() and not is_valid():
					timer_validation.stop()
			if translating:
				var trans = Vector3(event.relative.x, -event.relative.y, 0).normalized() * t_scale
				t_offset.x = clamp(t_offset.x + trans.x, -t_limit_x, t_limit_x)
				t_offset.y = clamp(t_offset.y + trans.y, -t_limit_y, t_limit_y)

func select(select: bool):
	selected = select

func solve():
	print(rot_basis, rot_goal)
	rot_basis = rot_goal

func is_valid():
	var x = rot_goal.x - rot_basis.x
	var y = rot_goal.y - rot_basis.y
	var z = rot_goal.z - rot_basis.z
	return x.length() < rot_margin and y.length() < rot_margin and z.length() < rot_margin

func _on_Timer_timeout():
	emit_signal("rotation_valid")
#	enable_horizontal = false
#	enable_vertical = false
	pass
