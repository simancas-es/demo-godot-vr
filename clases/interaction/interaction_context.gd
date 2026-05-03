extends RefCounted
class_name InteractionContext

enum SOURCE_KIND { UNKNOWN, FPV, COMPATIBILITY, TEST }

var playerdata: PlayerData = null
var source: Object = null
var source_kind: int = SOURCE_KIND.UNKNOWN
var source_label: StringName = &""
var room_request: Callable = Callable()

func _init(
		p_playerdata: PlayerData = null,
		p_source: Object = null,
		p_source_kind: int = SOURCE_KIND.UNKNOWN,
		p_source_label: StringName = &""
	) -> void:
	playerdata = p_playerdata
	source = p_source
	source_kind = p_source_kind
	source_label = p_source_label

static func from_fpv(p_playerdata: PlayerData, p_source: Object, p_room_request: Callable = Callable()) -> InteractionContext:
	var context := InteractionContext.new(p_playerdata, p_source, SOURCE_KIND.FPV, &"fpv")
	context.room_request = p_room_request
	return context

static func compatibility(p_source: Object = null, p_label: StringName = &"compatibility") -> InteractionContext:
	return InteractionContext.new(null, p_source, SOURCE_KIND.COMPATIBILITY, p_label)

func has_playerdata() -> bool:
	return playerdata != null

func get_inventory():
	if playerdata == null:
		return null
	return playerdata.get_inventory()

func request_room(room360) -> void:
	if room_request.is_valid():
		room_request.call(room360)
