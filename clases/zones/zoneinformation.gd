extends Resource
class_name ZoneInformation

@export var latitude : float
@export var longitude : float
@export var thumbnail : CompressedTexture2D

var _file: String
@export_file("*.json") var filepath_description : String:
	get:
		return _file
	set(value): #This is a hack but godot works like this or else it's null in the init.
		_file = value
		
var information : Dictionary
#var zone_title : String
#var zone_description : String

#TODO REFACTOR: Main environment should be described here,
# instead of this file going into the environment scene
@export_file var environment : String ##Path to scene

##ROOMS associated with this environment.
##Populating a room selector.
@export var room_ids : Array[ROOMS.ID] = [] ##This serves the purpose of pre-loading the rooms

func _init() -> void:
	#read_information.call_deferred()
	pass
	
func read_information() -> void:
	if (_file == "") or not FileAccess.file_exists(_file):
		_file = RESOURCES.ZONE_DESCRIPTION_TEMPLATE
	
	if FileAccess.file_exists(_file):
		var data = FileAccess.open(_file, FileAccess.READ)
		var parsed = JSON.parse_string(data.get_as_text())
		if not (parsed is Dictionary): push_error("Bad JSON! %s" % _file)
		information = parsed
