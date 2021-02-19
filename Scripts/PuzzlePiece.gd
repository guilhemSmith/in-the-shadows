extends Spatial

export var mesh: Resource = null

var rot_basis: Basis = Basis(Quat.IDENTITY)

export var enable_h: bool = true
export var h_scale: float = 0.01
export var h_start: float = 0.0

export var enable_vertical: bool = true
export var v_scale: float = 0.01
export var v_start: float = 0.0

export var enable_translations: bool = true
export var trans_offset: Vector3 = Vector3.ZERO
export var trans_scale: float = 0.05
export var trans_limit_x: float = 1.5
export var trans_limit_y: float = 1.0

var selected: bool = true
var rotating: bool = false
var translating: bool = false

onready var tween_node = $Tween
onready var timer_validation = $Timer
onready var model = $Model

func _ready():
	if model != null:
		model.set_mesh(mesh)
	rot_basis = rot_basis.rotated(Vector3.UP, h_start)
	rot_basis = rot_basis.rotated(Vector3.FORWARD, v_start)
	model.transform.basis = rot_basis

func _process(delta):
	if ((transform.origin - trans_offset).length() > 0.001):
		transform.origin = lerp(transform.origin, trans_offset, delta * 10)
	else:
		transform.origin = trans_offset
	model.transform.basis = model.transform.basis.slerp(rot_basis, delta * 10)

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
				if enable_h:
					rot_basis = rot_basis.rotated(Vector3.UP, event.relative.x * h_scale)
				if enable_vertical:
					rot_basis = rot_basis.rotated(Vector3.FORWARD, event.relative.y * v_scale)
			if translating:
				var trans = Vector3(event.relative.x, -event.relative.y, 0).normalized() * trans_scale
				trans_offset.x = clamp(trans_offset.x + trans.x, -trans_limit_x, trans_limit_x)
				trans_offset.y = clamp(trans_offset.y + trans.y, -trans_limit_y, trans_limit_y)
				

#func validate_angle(value, goal, margin):
#	return abs(dist_to_goal(value, goal)) <= margin

#func dist_to_goal(value, goal):
#	var angle = abs(value % 360 - goal)
#	if angle < 360 - angle:
#		return angle * sign(value)
#	else:
#		return (angle - 360) * sign(value)

func _on_Timer_timeout():
	print("validated")
#	var dist = dist_to_goal(horizontal_rot, horizontal_rot_goal)
#	horizontal_rot = -dist
#	update_rot()
