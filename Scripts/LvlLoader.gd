extends Spatial

var lvl_factory = Array()
export var lvl_index: int = 0

onready var main_loader = load("res://Scenes/MainMenu.tscn")

func _ready():
	lvl_factory.push_back(preload("res://Scenes/Levels/Lvl1.tscn"))
	lvl_factory.push_back(preload("res://Scenes/Levels/Lvl2.tscn"))
	lvl_factory.push_back(preload("res://Scenes/Levels/Lvl3.tscn"))
	lvl_factory.push_back(preload("res://Scenes/Levels/Lvl4.tscn"))
	load_lvl(lvl_index)

func load_lvl(new_lvl: int):
	lvl_index = new_lvl
	var lvl = lvl_factory[lvl_index].instance()
	lvl.connect("completed", self, "_on_puzzle_completed")
	add_child(lvl)

func _on_PauseMenu_quit_order():
	var root = get_tree().root
	root.remove_child(self)
	var instance = main_loader.instance()
	root.add_child(instance)
	queue_free()

func _on_puzzle_completed():
	print('hello')
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
		save.close()
