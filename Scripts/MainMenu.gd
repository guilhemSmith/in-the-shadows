extends Spatial


onready var lvl_loader = preload("res://Scenes/LvlLoader.tscn")
onready var lvlContainer = $CanvasLayer/Control/MarginContainer/VBoxContainer/MarginContainer/LvlContainer
var unlocked: int
const MAX_LVL: int = 4
var next_lvl = 0

func _ready():
	var save = File.new()
	if save.file_exists("user://unlocked_lvl.save"):
		save.open("user://unlocked_lvl.save", File.READ)
		unlocked = clamp(int(save.get_line()), 1, 4)
		save.close()
	else:
		unlocked = 1
		save.open("user://unlocked_lvl.save", File.WRITE)
		save.store_line(str(unlocked))
		save.close()
	

func _on_lvl_menu_pressed(debug):
	var limit = unlocked + 1
	if debug:
		limit = MAX_LVL + 1
	for i in range(1, limit):
		var lvl: Button = lvlContainer.get_node("Lvl" + str(i))
		if lvl != null:
			lvl.disabled = false
			lvl.connect("mouse_entered", self, "_on_Button_mouse_entered")
	for i in range(limit, MAX_LVL + 1):
		var lvl: Button = lvlContainer.get_node("Lvl" + str(i))
		if lvl != null:
			lvl.disabled = true
	$ClicSound.play()
	$AnimationTree.set("parameters/OneShotSelect/active", true)
	$AnimationTree.set("parameters/OneShotMain/active", false)

func _on_ResetButton_pressed():
	$ClicSound.play()
	unlocked = 1
	var save = File.new()
	save.open("user://unlocked_lvl.save", File.WRITE)
	save.store_line(str(unlocked))
	save.close()

func _on_MusicButton_pressed():
	$ClicSound.play()
	pass # Replace with function body.

func _on_Lvl_pressed(lvl):
	$ClicSound.play()
	next_lvl = lvl - 1
	if not $Timer.is_connected("timeout", self, "_on_Lvl_timeout"):
		$Timer.connect("timeout", self, "_on_Lvl_timeout", [], CONNECT_ONESHOT)
		$Timer.start()

func _on_Back_pressed():
	for i in range(1, MAX_LVL + 1):
		var lvl: Button = lvlContainer.get_node("Lvl" + str(i))
		if lvl != null:
			lvl.disabled = true
			if lvl.is_connected("mouse_entered", self, "_on_Button_mouse_entered"):
				lvl.disconnect("mouse_entered", self, "_on_Button_mouse_entered")
	$ClicSound.play()
	$AnimationTree.set("parameters/OneShotMain/active", true)
	$AnimationTree.set("parameters/OneShotSelect/active", false)


func _on_Button_mouse_entered():
	$HoverSound.play()


func _on_QuitButton_pressed():
	$ClicSound.play()
	if not $Timer.is_connected("timeout", self, "_on_Quit_timeout"):
		$Timer.connect("timeout", self, "_on_Quit_timeout", [], CONNECT_ONESHOT)
		$Timer.start()

func _on_Lvl_timeout():
	var root = get_tree().root
	root.remove_child(self)
	var instance = lvl_loader.instance()
	instance.lvl_index = next_lvl
	root.add_child(instance)
	queue_free()

func _on_Quit_timeout():
	get_tree().quit()

