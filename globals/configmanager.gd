extends Node
#PC Testing
#TODO: Error Handling of config. Reset
var config = ConfigFile.new()
const SETTINGS_FILEPATH = "user://settings.ini"

enum WINDOW_MODE {
	FULLSCREEN,
	WINDOWED,
	WINDOWEDBORDERLESS
}

enum RESOLUTION {
	r1152x648,
	r1280x720,
	r1600x900,
	r1920x1080
}

var RESOLUTION_VECTOR : Dictionary = {
	RESOLUTION.r1152x648 : Vector2i(1152, 648),
	RESOLUTION.r1280x720 : Vector2i(1280, 720),
	RESOLUTION.r1600x900 : Vector2i(1600, 900),
	RESOLUTION.r1920x1080 : Vector2i(1920, 1080),
}

func _ready():
	if !FileAccess.file_exists(SETTINGS_FILEPATH):
		config.set_value("keybinding", "move_up", "W")
		config.set_value("keybinding", "move_down", "S")
		config.set_value("keybinding", "move_left", "A")
		config.set_value("keybinding", "move_right", "D")
		config.set_value("keybinding", "interact", "E")
		config.set_value("keybinding", "menu", "Escape")
		config.set_value("keybinding", "map", "H")
		config.set_value("keybinding", "inventory", "Y")

		config.set_value("video", "windowmode", WINDOW_MODE.FULLSCREEN)
		config.set_value("video", "resolution", RESOLUTION.r1600x900)
		config.set_value("Game", "locale", "en")
		config.set_value("Game", "topic", TOPICS.LAYER.ABWASSER)
		
		config.save(SETTINGS_FILEPATH)
		
	else:
		config.load(SETTINGS_FILEPATH)
	update_config()
	return
		
		
func change_windowmode(window_mode : WINDOW_MODE) -> void:
	config.set_value("video", "windowmode", window_mode)
	update_config()
			
			
func change_resolution(resolution : RESOLUTION) -> void:
	config.set_value("video", "resolution", resolution)
	update_config()
	
func change_locale(locale : String) -> void:
	config.set_value("Game", "locale", locale)
	update_config()
	pass

func change_topic(topic : TOPICS.LAYER) -> void:
	config.set_value("Game", "topic", topic)
	update_config()
	print("Topic game: %s ... Topic config: %s" % [GameState._current_topic, config.get_value("Game", "topic", -1) ])
	


func update_config():
	var window_mode = config.get_value("video", "windowmode", WINDOW_MODE.WINDOWEDBORDERLESS)
	match window_mode:
		WINDOW_MODE.FULLSCREEN: #Fullscreen borderless
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		WINDOW_MODE.WINDOWED: #Window border
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		WINDOW_MODE.WINDOWEDBORDERLESS: #Window borderless
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
	
	var resolution = config.get_value("video", "resolution", RESOLUTION.r1600x900)
	var res_vector = RESOLUTION_VECTOR.get(resolution)
	DisplayServer.window_set_size(res_vector)
	
	var lan = config.get_value("Game", "locale", "en")
	var topic = config.get_value("Game", "topic", TOPICS.LAYER.ABWASSER)
	#topic = UTILS.log2_int(topic)
	topic = pow(2, topic)
	TranslationServer.set_locale(lan)
	GameState.on_request_change_topic(topic)
	
	config.save(SETTINGS_FILEPATH)
