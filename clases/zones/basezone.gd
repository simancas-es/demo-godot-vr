extends Node3D
class_name BaseZone

#Class that allows the creation of 3D environments and coupling them
#	with different 360x180º virtual ROOMS. These environments are called ZONES
#	and represent a more or less collection of buildings and rooms that have 
#	been modelled in 3D and that have some connection to the virtual rooms.
#	It is intended that the player is able to easily explore these 3D environments
#	and also load at certain spots the corresponding virtual room: for instance, 
#	a room that has been photographed with a 360x180º panorama.
#
#	Required data for this object are: the 3D mesh instances of the environment.
#	Plus RoomLoader objects placed at the specific points.
#
#	Ideally, this script is extended so as to define the behaviour of the
#	environment items

#@export var zone_information : ZoneInformation = null ##Refactored
#@export var zone_background : CompressedTexture2D = null
@export var north_point : Node3D #Reference from the Zone's 0,0,0, Ignores UP
@export var starting_position : Node3D #Starting position and rotation of the fpv
@export var starting_lookat : Node3D
@export var falcon_view : FalconView = null

signal finished_setup
##Not used as of now.
@export var navregion_default : NavigationRegion3D = null


##Don't forget to add a van
@export var van : SelectEnvironmentVan = null
var ENV_ID : ENVIRONMENTS.ID ##Identification of this environment. We pass it to the van.

var _room_positions : Array[RoomLoader] = [] #Information about the location of rooms within the 3D environment
var _last_geo_position : Vector3 #Last informaton about FPV
var _last_geo_rotation : Vector3 #Last rotation of the FPV
#
#var _cached_panorama_polygons : Dictionary[ROOMS.ID, Array] #Godot doesnt allow nested hints...
#var _data_rooms : Dictionary[ROOMS.ID, PanoramaData] = {}
#var _previous_room_id : ROOMS.ID = 0
#var _current_room_id : ROOMS.ID = 0
#var _current_room : Room360 = null

##Nodes that belong to only a particular topic
#Nodes outside of this will be always shown.
@export var _object_topics : Dictionary[TOPICS.LAYER, Array] = {}
var _current_topic : TOPICS.LAYER = TOPICS.LAYER.ABWASSER
#var _DEBUG = true

var signal_functions : Dictionary[Signal, Callable] = {
		#Signals.set_fixed_camera: set_fixed_camera,
		#Signals.set_falcon_camera: set_falcon_camera,
		#Signals.set_env_camera: set_env_camera ,
		#Signals.set_room_camera: set_room_camera,
		 Signals.topic_changed: set_topic,
		Signals.reset_position: _on_reset_position_player
	}


func _init(
	#current_room : ROOMS.ID = ROOMS.ID.NONE,
		#previous_room : ROOMS.ID = ROOMS.ID.NONE,
		last_geo_position : Vector3 = Vector3.ZERO,
		last_geo_rotation : Vector3 = Vector3.ZERO) -> void:
			#
	#_current_room_id = current_room
	#_previous_room_id = previous_room
	#
	#if last_geo_position != Vector3.ZERO:
	_last_geo_position = last_geo_position
	#if last_geo_rotation != Vector3.ZERO:
	_last_geo_rotation = last_geo_rotation

	pass

##Called only one time
func _ready() -> void:	
	#Connnect general signals
	tree_entered.connect(_on_enter_tree)
	tree_exited.connect(_on_exit_tree)
	
	_current_topic = GameState._current_topic
	
	_on_enter_tree()
	#
	#if not Signals.change_room.is_connected(_on_change_room):
		#Signals.change_room.connect(_on_change_room)
		
	

	pass

##Connect signals
func _on_enter_tree() -> void:
	_current_topic = GameState._current_topic
	##SIGNALS 
	#if not Signals.change_room.is_connected(_on_change_room):
		#Signals.change_room.connect(_on_change_room)
	
	for s : Signal in signal_functions.keys():
		if not s.is_connected(signal_functions[s]):
			s.connect(signal_functions[s])

	#LOAD VAN
	if van != null:
		van.id_from = ENV_ID
		
	#GET ROOMS
	for rl : RoomLoader in get_tree().get_nodes_in_group(GROUPS.ID.ROOMLOADER):
		_room_positions.append(rl)
		rl.north_reference = north_point
	
	init_after_entering_tree()
	

func init_after_entering_tree() -> void:
	##Reset positions
	reset_fpv_to_default_starting_position()#.call_deferred() #HACK. Not guaranteed...
	finished_setup.emit()
	
##Disconnect signals
func _on_exit_tree() -> void:
	##print("Zone %s exiting tree..." % ENV_ID)
	#if Signals.change_room.is_connected(_on_change_room):
			#Signals.change_room.disconnect(_on_change_room)
			#
	for s : Signal in signal_functions.keys():
		if s.is_connected(signal_functions[s]):
			s.disconnect(signal_functions[s])
	

func _on_reset_position_player() -> void:
	reset_fpv_to_default_starting_position()
	pass

##Aligns the position and look_at target for the FPV
func reset_fpv_to_default_starting_position() -> void:
	#LOAD FPV in this INSTANCE
	var spos
	var slookat
	if starting_position == null: spos = Vector3.ZERO
	else: spos = starting_position.position
	if starting_lookat == null: slookat = Vector3(0,0,-1)
	else: slookat = starting_lookat.position

	create_new_fpv.call_deferred(spos, slookat)
	
##Returns the position Node3D of the RoomLoader associated with this room.
func find_room_position(room : ROOMS.ID) -> Node3D:
	for roomloc in _room_positions:
		if room == roomloc.room_id:
			return roomloc
	return null #Not sure

##Teleport fpv to this point
func _on_changed_room(room : ROOMS.ID):
	#print("Change to room %s from environment %s" % [room, ENV_ID])
	var pos = find_room_position(room)
	if not pos : return
	var fpvs = get_fpvs()
	if fpvs: fpvs[0].global_position = pos.global_position
	return

##Changes the topic layer being visualized and deactivates whats not needed.
func set_topic(topic : TOPICS.LAYER) -> void:
	_current_topic = topic
	for k in _object_topics.keys():
		if k != topic:
			for node in _object_topics[k]:
				#node.visible = false
				if node.get("monitorable"): ##Cannot be accidentally activated
					node.monitorable = false
				if node is RoomLoader: node.visible = false ##Special case for these
	##First deactivate all, then activate if possible
	for k in _object_topics.keys():
		if k != topic:
			for node in _object_topics[k]:
				#node.visible = false
				if node.get("monitorable"): ##Cannot be accidentally activated
					node.monitorable = true
				if node is RoomLoader: node.visible = true ##Special case for these
	#if _current_room:
		#_current_room.set_topic(topic)

##Creates or reactivates a FPV instance and rotates it to the needed position.
func create_new_fpv(pos : Vector3 = Vector3.ZERO, look_target : Vector3 = Vector3.UP ) -> FPV:
	for c in get_children():
		if c is FPV:
			remove_child(c)
			c.queue_free()
	##HACK. TODO. Optimize.
	var fpv = preload(RESOURCES.FPV).instantiate()
	add_child(fpv)
	assert (fpv.is_node_ready())
	assert (fpv.camera)
	assert (get_parent() and get_parent().is_inside_tree())
	fpv.position = pos	
	if pos != look_target: #TODO. Possible bugs
		if look_target != Vector3.UP:
			#look_target = starting_lookat.position
			fpv.look_at(look_target)
	
	#Start with env
	set_env_camera(fpv)
	
	fpv.entered_mode_room.connect(_on_changed_room)
	#fpv.entered_mode_falcon.connect(set_falcon_camera.bind(fpv))
	#fpv.entered_mode_env.connect(set_env_camera.bind(fpv))
	
	#set_env_camera(fpv)
	return fpv
#
func set_env_camera(fpv : FPV) -> void:
	fpv.set_mode_environment()
	#fpv.set_background(zone_background)
	#fpv.rotate_sky(PI, true)

	#
#func set_room_camera() -> void:
	#fpv.set_mode_panorama(null)
#
#func set_fixed_camera(keep_bg : bool) -> void:
	#fpv.set_mode_fixed(keep_bg)
	#pass

func set_falcon_camera(fpv : FPV) -> void:
	fpv.set_mode_falcon()
	pass
#
#func on_escape():
	##If the user presses Escape it either quits the room or launches a menu
	#if _current_room == null: print("Launching escape from scene...")
	#else:
		#on_exit_room()
#
#func on_exit_room():
	#print("Launching escape from room...TODO: Save geodata?.")
	#if _current_room: ##Cache the room
		#_cached_panorama_polygons[_current_room_id] = _current_room.get_cached_polygons()
		#_current_room.exit_panorama()
		#
		##Just in case disable all connections
		#if not _current_room.exit_room_triggered.get_connections().is_empty():
			#for c in _current_room.exit_room_triggered.get_connections():
				#_current_room.exit_room_triggered.disconnect(c.callable)
	#
	#var rl = find_room_position(_current_room_id)
	#_last_geo_position = rl.position #HACK... position, geo position, rl position all tangled
	###Disable
	#_current_room = null
	#
	###Teleport player to position
	#
	#
	#show_zone()
		#

func show_zone() -> void:
	#if _current_room: remove_child(_current_room)
	#for c in get_children():
		#if not (c is Node3D) or (c is Control) : continue ##TODO Fragile because of Node(-)
		#if c is PanoramaData:	c.visible = false; continue;
		#c.visible = true
		##c.set_process(true)
	#if _current_room != null :
		#_current_room.visible = false
		##_current_room.set_process(false)
	
	#if not _last_geo_position: _last_geo_position = starting_position.position
	
	var fpv = await create_new_fpv(_last_geo_position)
	#Signals.set_env_camera.emit()
	#set_env_camera(fpv)
func get_fpvs() -> Array[FPV]:
	var array : Array[FPV]
	for fpv in get_tree().get_nodes_in_group("FPV"):
		array.append(fpv)
	return array
	
#func _process(delta: float) -> void:
	#print("DEBUG _current_room:",_current_room)
