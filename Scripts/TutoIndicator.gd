extends Control

func _on_StartTuto(name: String):
	$AnimationPlayer.play(name)

func _on_StopTuto():
	$AnimationPlayer.play("Hidden")
