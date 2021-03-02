extends AudioStreamPlayer

export(Array, Resource) var musics

var index: int

func _ready():
	if musics.size() > 0:
		randomize()
		index = randi() % musics.size()
		set_stream(musics[index])
		play()

func _on_MusicManager_finished():
	if musics.size() > 0:
		index = (index + 1) % musics.size()
		set_stream(musics[index])
		play()
