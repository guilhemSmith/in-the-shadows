extends Spatial

var lvl_factory = Array()
export var lvl_index: int = 0

var current_lvl = null

var main_scene = null
onready var res_loader = ResourceLoader.load_interactive("res://Scenes/MainMenu.tscn")

func _ready():
	lvl_factory.push_back(preload("res://Scenes/Levels/Lvl1.tscn"))
	lvl_factory.push_back(preload("res://Scenes/Levels/Lvl2.tscn"))
	lvl_factory.push_back(preload("res://Scenes/Levels/Lvl3.tscn"))
	lvl_factory.push_back(preload("res://Scenes/Levels/Lvl4.tscn"))
	load_lvl(lvl_index)

func _process(delta):
	if res_loader != null && res_loader.poll() == ERR_FILE_EOF:
		print("load done")
		main_scene = res_loader.get_resource()
		res_loader = null

func load_lvl(new_lvl: int):
	lvl_index = new_lvl
	current_lvl = lvl_factory[lvl_index].instance()
	current_lvl.connect("completed", self, "_on_puzzle_completed")
	add_child(current_lvl)

func _on_PauseMenu_quit_order():
	if main_scene == null:
		res_loader.wait()
		main_scene = res_loader.get_resource()
		res_loader = null
	var instance = main_scene.instance()
	var root = get_tree().root
	root.remove_child(self)
	root.add_child(instance)
	queue_free()

func _on_puzzle_completed():
	print("completed")
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
	$Timer.start()


func _on_PauseMenu_next_order():
	if current_lvl != null:
		current_lvl.move_away()
	load_lvl(lvl_index + 1)


func _on_Timer_timeout():
	$CanvasLayer/PauseMenu.next_menu(lvl_index + 1 < lvl_factory.size())
