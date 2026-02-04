extends BaseDialog
class_name MenuSettings
#
#signal go_back

const wm_fs = "Fullscreen"
const wm_w = "Window"
const wm_bw = "Borderless Window"
var _t = [tr(wm_fs), tr(wm_w, "Window mode as an option"), tr(wm_bw)]

const WINDOW_MODE : Dictionary = {
	ConfigManager.WINDOW_MODE.FULLSCREEN : wm_fs  ,
	ConfigManager.WINDOW_MODE.WINDOWED : wm_w ,
	ConfigManager.WINDOW_MODE.WINDOWEDBORDERLESS : wm_bw  
}

const RESOLUTION_NAME : Dictionary = {
	ConfigManager.RESOLUTION.r1152x648 : "1152x648"  ,
	ConfigManager.RESOLUTION.r1280x720 : "1280x720"  ,
	ConfigManager.RESOLUTION.r1600x900 : "1600x900"  ,
	ConfigManager.RESOLUTION.r1920x1080 : "1920x1080"  ,
}


@export var options_windowmode : OptionButton
@export var options_resolution : OptionButton
@export var options_language : OptionButton
@export var options_topic : OptionButton

func enter() -> void:
	visible = true
	set_process_input(true)
	#self.requested_lock.emit()
	self.opened_dialog.emit()


func exit() -> void:
	visible = false
	set_process_input(false)
	#self.released_lock.emit()
	self.closed_dialog.emit()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("escape"):
		print("Escape pressed while in Settings...")
		get_viewport().set_input_as_handled()
		exit()

func _ready() -> void:
	set_process_input(false)
	repopulate_menus()
	
	#PRESELECT
	ready_preselect()
	
	#Connect selections
	options_windowmode.item_selected.connect(on_windowmode_selected)
	options_resolution.item_selected.connect(on_resolution_selected)
	options_language.item_selected.connect(on_language_selected)
	options_topic.item_selected.connect(on_topic_selected)
	
	#button_back.button_up.connect(on_button_back_up)

func ready_preselect():
	#Get Enums
	var windowmode_setting = ConfigManager.config.get_value("video", "windowmode")
	var resolution_setting = ConfigManager.config.get_value("video", "resolution")
	var locale = TranslationServer.get_locale()

	#get indexes order
	var options_window_idx = WINDOW_MODE.keys().find(windowmode_setting)
	var options_res_idx = RESOLUTION_NAME.keys().find(resolution_setting)
	var options_lan_idx =  TranslationServer.get_loaded_locales().find(locale)
	if options_lan_idx <0 :
		options_lan_idx = 0
		push_warning("Couldn't find locale %s..." % locale)
	
	#Topics is a bitmask
	var options_topic_idx = TOPICS.LAYER.keys().find(GameState._current_topic)
	if options_topic_idx <0 :
		options_topic_idx = TOPICS.LAYER.ABWASSER
		push_warning("Current topic in GameState is null... changing to %s" % options_topic_idx)
		GameState.on_request_change_topic(options_topic_idx)
	options_topic_idx = UTILS.log2_int(options_topic_idx)
	
	options_windowmode.select(options_window_idx)
	options_resolution.select(options_res_idx)
	options_language.select(options_lan_idx)
	options_topic.select(options_topic_idx)
		
func on_windowmode_selected(idx : int) -> void:
	var mode = WINDOW_MODE.keys()[idx]
	ConfigManager.change_windowmode(mode)

func on_resolution_selected(idx : int) -> void:
	var res = RESOLUTION_NAME.keys()[idx]
	ConfigManager.change_resolution(res)

func on_language_selected(idx : int) -> void:
	var lan = TranslationServer.get_loaded_locales()[idx]
	ConfigManager.change_locale(lan)
	pass

func on_topic_selected(idx : int) -> void:
	#var topic = TOPICS.LAYER.keys()[idx]
	ConfigManager.change_topic(idx)
	pass

func on_button_back_up():
	exit()

func repopulate_menus():
	##Update names. TODO deduplicate.
	var idx : int
	
	idx = options_windowmode.selected
	options_windowmode.clear()
	for wm in WINDOW_MODE.values():
		options_windowmode.add_item(tr(wm))
	
	idx = options_resolution.selected
	options_resolution.clear()
	for res in RESOLUTION_NAME.values():
		options_resolution.add_item(tr(res))
	
	idx = options_language.selected
	options_language.clear()
	for language in TranslationServer.get_loaded_locales():
		options_language.add_item(tr(language))
	options_language.select(idx)
	
	idx = options_topic.selected
	options_topic.clear()
	for key in TOPICS.LAYER.values():
		if not (key in TOPICS.LAYERNAMES) : continue
		var tname = tr(TOPICS.LAYERNAMES[key])
		options_topic.add_item(tr(tname))
	options_topic.select(idx)
	
##Listen to changes in the locale
func _notification(what):
	if what == NOTIFICATION_TRANSLATION_CHANGED :
		repopulate_menus()
