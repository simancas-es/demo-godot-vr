extends Node
#class_name AudioManager

var audiostream_single : AudioStreamPlayer = AudioStreamPlayer.new()
var loaded_sounds : Dictionary[String, AudioStreamMP3] = {}


func _ready() -> void:
	Signals.play_sound.connect(on_play_sound)
	#Signals.play_loop.connect(on_play_loop)
	add_child(audiostream_single)
	
	pass
	

#func on_play_loop(res_path : String) -> void:
##Caches mp3 res_path as streams
func cache_sound(res_path : String) -> AudioStreamMP3:
	var stream = load(res_path)
	loaded_sounds[res_path] = stream
	return stream
	
func on_play_sound(res_path : String) -> void:
	if res_path in loaded_sounds:
		audiostream_single.stream = loaded_sounds[res_path]
	else:
		var stream = cache_sound(res_path)
		audiostream_single.stream = stream
	audiostream_single.play()
	return
	
	
