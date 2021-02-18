extends Spatial

export var model: Resource = null

export var enable_horizontal: bool = true
export var horizontal_rot: int = 0
export var horizontal_rot_goal: int = 0
export var horizontal_rot_margin: int = 5
export var horizontal_rot_scale: float = 0.3

export var enable_vertical: bool = true
export var vertical_rot: int = 0
export var vertical_rot_goal: int = 0
export var vertical_rot_margin: int = 5
export var vertical_rot_scale: float = 0.3

export var enable_translations: bool = true
export var trans_horizontal: float = 0
export var trans_vertical: float = 0
export var trans_scale: float = 0.05
export var trans_limit_x: float = 1.5
export var trans_limit_y: float = 1.0

export var ease_duration: float = 1.0
export var validation_duration: float = 1.0

onready var FORWARD = transform.basis.z.normalized()
onready var UP = transform.basis.y.normalized()

var selected: bool = true
var rotating: bool = false
var translating: bool = false

onready var tween_node = $Tween
onready var timer_validation = $Timer

func _ready():
	if model != null:
		$Model.set_mesh(model)
	rotation_degrees = Vector3(0, horizontal_rot, 0)

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
					horizontal_rot = event.relative.x * horizontal_rot_scale
				if enable_vertical:
					vertical_rot = event.relative.y * vertical_rot_scale
				update_rot()
				var valid = validate_angle(horizontal_rot, horizontal_rot_goal, horizontal_rot_margin)
				if timer_validation.is_stopped() and valid:
					timer_validation.start(validation_duration)
				elif not timer_validation.is_stopped() and not valid:
					timer_validation.stop()
			if translating:
				var trans = Vector3(event.relative.x, -event.relative.y, 0).normalized() * trans_scale
				trans.x = clamp(trans.x, -trans_limit_x - trans_horizontal, trans_limit_x -trans_horizontal)
				trans.y = clamp(trans.y, -trans_limit_y - trans_vertical, trans_limit_y -trans_vertical)
				translate(trans)
				trans_horizontal += trans.x
				trans_vertical += trans.y
				

func update_rot():
	rotate(UP, deg2rad(horizontal_rot))
	rotate(FORWARD, deg2rad(vertical_rot))

func validate_angle(value, goal, margin):
	return abs(dist_to_goal(value, goal)) <= margin

func dist_to_goal(value, goal):
	var angle = abs(value % 360 - goal)
	if angle < 360 - angle:
		return angle * sign(value)
	else:
		return (angle - 360) * sign(value)

func _on_Timer_timeout():
	print("validated")
	var dist = dist_to_goal(horizontal_rot, horizontal_rot_goal)
	horizontal_rot = -dist
	update_rot()
