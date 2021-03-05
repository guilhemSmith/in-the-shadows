tool
extends Spatial

var lvl_factory = Array()
export var lvl_index: int = 0

var current_lvl = null
var tuto_state: int = 0

func _ready():
	lvl_factory.push_back("res://Scenes/Levels/Lvl1.tscn")
	lvl_factory.push_back("res://Scenes/Levels/Lvl2.tscn")
	lvl_factory.push_back("res://Scenes/Levels/Lvl3.tscn")
	lvl_factory.push_back("res://Scenes/Levels/Lvl4.tscn")
	load_lvl(lvl_index)

func load_lvl(new_lvl: int):
	lvl_index = new_lvl
	current_lvl = load(lvl_factory[lvl_index]).instance()
	current_lvl.tuto_current = max(tuto_state, current_lvl.tuto_current)
	current_lvl.connect("completed", self, "_on_puzzle_completed")
	current_lvl.connect("start_tuto", $CanvasLayer/TutoIndicator, "_on_StartTuto")
	current_lvl.connect("stop_tuto", $CanvasLayer/TutoIndicator, "_on_StopTuto")
	current_lvl.connect("stop_tuto", self, "_on_StopTuto")
	add_child(current_lvl)

func _on_PauseMenu_quit_order():
	var instance = load("res://Scenes/MainMenu.tscn").instance()
	var root = get_tree().root
	var music = get_node("MusicManager")
	remove_child(music)
	instance.get_node("MusicManager").replace_by(music)
	instance.tuto = tuto_state
	root.remove_child(self)
	root.add_child(instance)
	queue_free()

func _on_puzzle_completed():
	var save = File.new()
	var new_unlock: int = lvl_index + 2
	var old_unlock: int = 0
	if save.file_exists("user://unlocked_lvl.save"):
		save.open("user://unlocked_lvl.save", File.READ)
		old_unlock = clamp(int(save.get_line()), 1, 4)
		save.close()
	if new_unlock > old_unlock:
		save.open("user://unlocked_lvl.save", File.WRITE)
		save.store_line(str(new_unlock))
		save.store_line(str(tuto_state))
		save.close()
	$Gong.play()
	$AnimationPlayer.play("Success")
	$Timer.start()


func _on_PauseMenu_next_order():
	if current_lvl != null:
		current_lvl.move_away()
	load_lvl(lvl_index + 1)


func _on_Timer_timeout():
	$CanvasLayer/PauseMenu.next_menu(lvl_index + 1 < lvl_factory.size())

func _on_StopTuto(new_state):
	if new_state > tuto_state:
		tuto_state = new_state
		var save = File.new()
		var unlock: int = 0
		if save.file_exists("user://unlocked_lvl.save"):
			save.open("user://unlocked_lvl.save", File.READ)
			unlock = max(clamp(int(save.get_line()), 1, 4), lvl_index + 2)
			save.close()
		save.open("user://unlocked_lvl.save", File.WRITE)
		save.store_line(str(unlock))
		save.store_line(str(tuto_state))
