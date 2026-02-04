extends Node


##Loaded .tres of each environment
var LOADED_ENVIRONMENTS_INFO : Dictionary[ENVIRONMENTS.ID, ZoneInformation] = {}

##Basezones
var LOADED_ENVIRONMENTS : Dictionary[ENVIRONMENTS.ID, BaseZone] = {
}

##Not Room360 but PanoramaData
var LOADED_ROOM_DATA : Dictionary[ROOMS.ID, PanoramaData] = {
}

var CACHED_ROOM360 : Dictionary[ROOMS.ID, Room360] = {
	
}

func _ready() -> void:
	#Signals.precache_room.connect(on_precache_room)
	#Signals.precache_zone.connect(on_precache_zone)
	#
	var env_keys = ENVIRONMENTS.ID.values()
	var info_keys = ENVIRONMENTS.ZONEINFORMATION.keys()		
	
	for id in env_keys:
		if not (id in info_keys):
			push_warning("Missing key %s in ENVIRONMENTS.ZONEINFORMATION." % id)
			continue
		var res_zone : String = ENVIRONMENTS.ZONEINFORMATION[id]
		var zone_info : ZoneInformation = await load(res_zone)
		LOADED_ENVIRONMENTS_INFO[id] = zone_info
		
		if LOADED_ENVIRONMENTS_INFO[id] == null:
			push_error("Couldn't load environment in Cache function: %s" % res_zone)
			continue
		zone_info.read_information()
		if LOADED_ENVIRONMENTS_INFO[id].information.is_empty():
			push_error("Couldn't load environment information... %s is empty!" % res_zone)
	
	#
#func on_precache_zone(_id : ENVIRONMENTS.ID):
	#pass	
#func on_precache_room(_id : ROOMS.ID):
	#pass
	#

#There should be only one of each room and environment at most, so we instantiate them
#Make async with Resourceloader thread
##Caches room
func load_room(room : ROOMS.ID) -> PanoramaData:
	if room in LOADED_ROOM_DATA : return LOADED_ROOM_DATA[room]
	if room == ROOMS.ID.NONE : return null
		
	var path = ROOMS.SCENES[room]
	ResourceLoader.load_threaded_request(path)
	while true:
		var res = ResourceLoader.load_threaded_get_status(path)
		if res == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			pass
		elif res == ResourceLoader.THREAD_LOAD_LOADED:
			break
		await get_tree().create_timer(0.1).timeout

	var room_data : PanoramaData = ResourceLoader.load_threaded_get(path).instantiate()
	if not (room_data is PanoramaData):
		push_error("Room couldnt be loaded. It's not a PanoramaData object.")
		return null
	LOADED_ROOM_DATA[room] = room_data
	return LOADED_ROOM_DATA[room]
	
	
##Caches environment
func load_environment(env : ENVIRONMENTS.ID) -> BaseZone:
	if env in LOADED_ENVIRONMENTS : return LOADED_ENVIRONMENTS[env]
	
	var path : String = LOADED_ENVIRONMENTS_INFO[env].environment
	ResourceLoader.load_threaded_request(path)
	while true:
		var res = ResourceLoader.load_threaded_get_status(path)
		if res == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			pass
		elif res == ResourceLoader.THREAD_LOAD_LOADED:
			break
		await get_tree().create_timer(0.3).timeout

	var zone : BaseZone = ResourceLoader.load_threaded_get(path).instantiate()
	if not (zone is BaseZone):
		push_error("Zone couldnt be loaded. It's not a BaseZone.")
		return null
	LOADED_ENVIRONMENTS[env] = zone
	
	##Load each room inside the 
	for room in LOADED_ENVIRONMENTS_INFO[env].room_ids:
		load_room(room)
	
	return LOADED_ENVIRONMENTS[env]

func get_room(room : ROOMS.ID) -> PanoramaData:
	if room in LOADED_ROOM_DATA:
		return LOADED_ROOM_DATA[room]
	return null

func get_env_info(env : ENVIRONMENTS.ID) -> ZoneInformation:
	return LOADED_ENVIRONMENTS_INFO[env]
	
func get_environment(env : ENVIRONMENTS.ID) -> Node3D:
	if env in LOADED_ENVIRONMENTS:
		return LOADED_ENVIRONMENTS[env]
	return null
	
func load_asynchronous(path : String, tree_backup : SceneTree = null) -> Resource:
	ResourceLoader.load_threaded_request(path)
	while true:

		var res = ResourceLoader.load_threaded_get_status(path)
		if res == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			pass
		elif res == ResourceLoader.THREAD_LOAD_LOADED:
			break
		var tree = get_tree()
		if tree == null : tree = tree_backup
		await tree.create_timer(0.3).timeout
	var obj : Resource = ResourceLoader.load_threaded_get(path)
	return obj

##Stores a created room into a cache storage
func store_in_cache_room360(id : ROOMS.ID, room360 : Room360) -> void:
	if room360:
		CACHED_ROOM360[id] = room360
	else:
		pass
##Retrieves a ROom360 if available in the cache
func retrieve_room360(id : ROOMS.ID) -> Room360:
	if id in CACHED_ROOM360:
		return CACHED_ROOM360[id]
	else:
		return null
