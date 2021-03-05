extends Spatial

onready var music_panel = $CanvasLayer/Control/MarginContainer/VBoxContainer/MarginContainer/Panel
var lvl_loader = "res://Scenes/LvlLoader.tscn"
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
	lvlContainer.get_node("VBoxContainer/Label").text = $LvlSelector.get_title()
	$AnimationTree.set("parameters/OneShotDark/active", true)

func _on_lvl_menu_pressed(debug):
	var limit = unlocked
	if debug:
		limit = MAX_LVL
	$LvlSelector.unlock_lvl(limit)
	$ClicSound.play()
	$LvlSelector.enabled = true
	$AnimationTree.set("parameters/BlendSpace1DSubMenu/blend_position", -1)
	$AnimationTree.set("parameters/OneShotSubMenu/active", true)

func _on_ResetButton_pressed():
	$ClicSound.play()
	unlocked = 1
	var save = File.new()
	save.open("user://unlocked_lvl.save", File.WRITE)
	save.store_line(str(unlocked))
	save.close()

func _on_MusicButton_pressed():
	$ClicSound.play()
	music_panel.visible = true

func _on_Play_pressed():
	$ClicSound.play()
	next_lvl = $LvlSelector.lvl_selected() - 1
	if next_lvl >= 0:
		$AnimationTree.set("parameters/BlendSpace1DDark/blend_position", -1)
		$AnimationTree.set("parameters/OneShotDark/active", true)
		if not $Timer.is_connected("timeout", self, "_on_Lvl_timeout"):
			$Timer.connect("timeout", self, "_on_Lvl_timeout", [], CONNECT_ONESHOT)
			$Timer.start(.5)

func _on_Back_pressed():
	$ClicSound.play()
	$LvlSelector.enabled = false
	$AnimationTree.set("parameters/BlendSpace1DSubMenu/blend_position", 1)
	$AnimationTree.set("parameters/OneShotSubMenu/active", true)


func _on_Button_mouse_entered():
	$HoverSound.play()


func _on_QuitButton_pressed():
	$ClicSound.play()
	if not $Timer.is_connected("timeout", self, "_on_Quit_timeout"):
		$Timer.connect("timeout", self, "_on_Quit_timeout", [], CONNECT_ONESHOT)
		$Timer.start()

func _on_Lvl_timeout():
	var instance = load(lvl_loader).instance()
	var root = get_tree().root
	var music = $MusicManager
	root.remove_child(self)
	remove_child(music)
	instance.get_node("MusicManager").replace_by(music)
	instance.lvl_index = next_lvl
	root.add_child(instance)
	queue_free()

func _on_Quit_timeout():
	get_tree().quit()


func _on_MeydanButton_pressed():
	OS.shell_open("https://meydan.bandcamp.com/")


func _on_LicenceButton_pressed():
	OS.shell_open("https://creativecommons.org/licenses/by/3.0/")


func _on_MusicBack_pressed():
	$ClicSound.play()
	music_panel.visible = false


func _on_LvlSelector_new_title(title):
	lvlContainer.get_node("VBoxContainer/Label").text = title
