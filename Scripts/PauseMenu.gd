extends Control

export var speed: float = 5


var actif: bool = false

signal quit_order
signal next_order

func _ready():
	$AnimationPlayer.play("Start")

func _input(event):
	if event.is_action_pressed("ui_menu"):
		get_tree().paused = not actif
		actif = not actif
		if actif:
			$AnimationPlayer.play("popin")
		else:
			$AnimationPlayer.play("popout")

func next_menu(enable: bool):
	get_tree().paused = not actif
	
	actif = not actif
	if enable:
		$AnimationPlayer.play("popin next")
	else:
		$AnimationPlayer.play("popin")

func _on_ResumeButton_pressed():
	get_tree().paused = false
	actif = false
	$AnimationPlayer.play("popout")
	$ClicSound.play()

func _on_NextButton_pressed():
	get_tree().paused = false
	actif = false
	$AnimationPlayer.play("popout next")
	$ClicSound.play()
	emit_signal("next_order")

func _on_QuitButton_pressed():
	$ClicSound.play()
	$AnimationPlayer.play("Quit")
	$Timer.start()

func _on_Button_mouse_entered():
	if actif:
		$HoverSound.play()


func _on_Timer_timeout():
	get_tree().paused = false
	emit_signal("quit_order")
