extends ScrollContainer
class_name EnvSelectorEntryContainer

signal change_current_selected(id : ENVIRONMENTS.ID)
signal load_current

@onready var vbcontainer : VBoxContainer = $VBoxContainer

func _gui_input(_event: InputEvent) -> void:
	#print("ScrollEnv: ", event)
	pass

func populate_entries():	
	for c in vbcontainer.get_children():
		vbcontainer.remove_child(c)
		c.queue_free()
	var locale = TranslationServer.get_locale()
	var env_info_keys = Cache.LOADED_ENVIRONMENTS_INFO.keys()
	for i in env_info_keys:
		var zone = Cache.LOADED_ENVIRONMENTS_INFO[i]
		var information = zone.information
		var entry : EnvEntry = await load(RESOURCES.MENU_ENVSELECT_ENTRY).instantiate()
		
		if not (locale in information) : locale = "en"
		if not (locale in information) :
			push_error("Missing locale %s in dictionary %s , from environment %s" % [locale, information, i])
			
		entry.call_deferred("populate_entry",
							 i,
							 information[locale]["zone_title"],
							 information[locale]["zone_description"],
							 zone.thumbnail,
							 Vector2(zone.latitude, zone.longitude)
							)
		vbcontainer.add_child(entry)
		
	pass

func connect_to_children():
	for ch in vbcontainer.get_children():
		if ch is EnvEntry:
			var c : EnvEntry = ch
			if not c.entry_selected.is_connected(on_update_selection):
				c.entry_selected.connect(on_update_selection)
			if not c.entry_doubleclicked.is_connected(on_doubleclick_entry):
				c.entry_doubleclicked.connect(on_doubleclick_entry)
	
func _ready() -> void:
	populate_entries.call_deferred()
	connect_to_children.call_deferred()

func on_doubleclick_entry(env_id : ENVIRONMENTS.ID, _coor_latlong : Vector2):
	change_current_selected.emit(env_id)
	load_current.emit()
	

func on_update_selection(env_id : ENVIRONMENTS.ID, _coor_latlong : Vector2):
	change_current_selected.emit(env_id)
	
	
##Listen to changes in the locale
func _notification(what):
	if what == NOTIFICATION_TRANSLATION_CHANGED :
		_ready()
