extends Control

export var speed: float = 5


var actif: bool = false

signal quit_order

onready var resume_button = $MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/ResumeButton
onready var quit_button = $MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/QuitButton

func _ready():
	modulate = Color.transparent
	visible = false
	resume_button.disabled = true
	quit_button.disabled = true

func _input(event):
	if event.is_action_pressed("ui_menu"):
		get_tree().paused = not actif
		actif = not actif
		if actif:
			$AnimationPlayer.play("popin")
		else:
			$AnimationPlayer.play("popout")

func _on_ResumeButton_pressed():
	get_tree().paused = false
	actif = false
	$AnimationPlayer.play("popout")
	$ClicSound.play()

func _on_QuitButton_pressed():
	$ClicSound.play()
	$Timer.start()

func _on_Button_mouse_entered():
	if actif:
		$HoverSound.play()


func _on_Timer_timeout():
	get_tree().paused = false
	emit_signal("quit_order")
