extends Spatial

export var enable_horizontal: bool = true
export var horizontal_rot: int = 90
export var horizontal_rot_goal: int = 0
export var horizontal_rot_margin: int = 5

export var ease_duration: float = 1.0

var selected: bool = true
var rotating: bool = false
onready var tween_node = $Tween
onready var timer_validation = $Timer

func _ready():
	rotation_degrees = Vector3(0, horizontal_rot, 0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	pass

func _input(event):
	if selected:
		if event is InputEventMouseButton and event.get_button_index() == 1:
			rotating = event.is_pressed()
		if rotating and event is InputEventMouseMotion:
			print(event.relative.x)
			horizontal_rot += event.relative.x / 2
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
			if horizontal_rot % 360 == horizontal_rot_goal:
				print("correct: ", horizontal_rot % 360)
