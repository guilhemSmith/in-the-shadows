extends Spatial

export var enable_horizontal: bool = true
export var horizontal_rot: int = 90
export var horizontal_rot_goal: int = 0
export var horizontal_rot_margin: int = 5
export var horizontal_rot_scale: float = 0.25

export var ease_duration: float = 1.0
export var validation_duration: float = 1.0

var selected: bool = true
var rotating: bool = false
onready var tween_node = $Tween
onready var timer_validation = $Timer

func _ready():
	rotation_degrees = Vector3(0, horizontal_rot, 0)

func _input(event):
	if selected:
		if event is InputEventMouseButton and event.get_button_index() == 1:
			rotating = event.is_pressed()
		if rotating and event is InputEventMouseMotion:
			if enable_horizontal:
				horizontal_rot += event.relative.x * horizontal_rot_scale
			update_rot()
			var valid = validate_angle(horizontal_rot, horizontal_rot_goal, horizontal_rot_margin)
			if timer_validation.is_stopped() and valid:
				timer_validation.start(validation_duration)
			elif not timer_validation.is_stopped() and not valid:
				timer_validation.stop()

func update_rot():
	tween_node.interpolate_property(
		self,
		"rotation_degrees",
		rotation_degrees,
		Vector3(0, horizontal_rot, 0),
		ease_duration,
		Tween.TRANS_EXPO,
		Tween.EASE_OUT
	)
	if not tween_node.is_active():
		tween_node.start()

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
	horizontal_rot -= dist
	update_rot()
