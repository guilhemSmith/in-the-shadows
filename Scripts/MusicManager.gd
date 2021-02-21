extends AudioStreamPlayer

export(Array, Resource) var musics

onready var index: int = randi() % musics.size()

func _ready():
	set_stream(musics[index])
	play()

func _on_MusicManager_finished():
	index = (index + 1) % musics.size()
	set_stream(musics[index])
	play()
