extends Control

export var speed: float = 5


var actif: bool = false

func _ready():
	modulate = Color.transparent

func _process(delta):
	if actif and modulate.a < 1:
		modulate = modulate.linear_interpolate(Color.white, delta * speed)
	elif modulate.a > 0:
		modulate = modulate.linear_interpolate(Color.transparent, delta * speed * 2)
	elif not actif:
		visible = false

func _input(event):
	if event.is_action_pressed("ui_menu"):
		get_tree().paused = not actif
		actif = not actif
		if actif:
			visible = true
		$MarginContainer/VBoxContainer/ResumeButton.disabled = not actif
		$MarginContainer/VBoxContainer/QuitButton.disabled = not actif

func _on_ResumeButton_pressed():
	get_tree().paused = false
	actif = false
	$MarginContainer/VBoxContainer/ResumeButton.disabled = true
	$MarginContainer/VBoxContainer/QuitButton.disabled = true
	$ClicSound.play()

func _on_QuitButton_pressed():
	$ClicSound.play()
	$Timer.start()

func _on_Button_mouse_entered():
	if actif:
		$HoverSound.play()


func _on_Timer_timeout():
	get_tree().quit()
