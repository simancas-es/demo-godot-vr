extends Node3D
class_name Room360

var id : ROOMS.ID = ROOMS.ID.NONE
var data : PanoramaData = null 
#Panorama variables
var _panorama_polygons : Array[DataPolygonLocation] = []

var _north_ref : Node3D
var angle_fw2 : float #x,y from 2D data before transform
var angle_fw3 : float #x,y,z from 3D zone
var _angle_diff : float = 0.0 #diff 3d to 2d ref

var _DEBUG = false

var signal_functions : Dictionary[Signal, Callable] = {
							Signals.topic_changed: set_topic,	
}

signal request_change_internal_room(room360 : Room360)
signal exit_room_triggered_to(door_to: ROOMS.ID, context: InteractionContext)

func exit_panorama() -> void:
	clean()
	queue_free()
	
func clean():
	#Clear non-panorama things
	for c in _panorama_polygons:
		#c.queue_free() #Don't free them because we are caching them.
		self.remove_child(c)
	_panorama_polygons.clear()

func get_cached_polygons() -> Array[DataPolygonLocation]:
	return _panorama_polygons


##Instantiates a Room360 Object which is a structure that holds
##a number of interactive panels in the panorama_polygons.
##The references serve as orientation for the player:
##The player is centered at the center_reference for better immersion.
##It is possible to pass the cached panorama_polygons to save on generation.
func _init(data_ : PanoramaData) -> void:
	clean()
	id = data_.room_id
	data = data_
	var polygons : Array[PanoramaInformationPolygon] = data.polygons		
	
	var texture = get_texture()
	if not texture:
		push_error("Tried to create a Room360 without a texture!")
		queue_free()
		return 
	
	
	#Instantiate panels
	for poly in polygons:
		##GEOMETRY
		var polygons_3d : Array[InteractivePanel] = []
		for subpoly in poly.subdivision:
			var points = UTILS.get_polygon_points_3d(subpoly, data.L, data.W)
			var ip = InteractivePanel.new(points, poly.albedocolor, false, _DEBUG)	
			polygons_3d.append(ip)
			ip.visible_mesh.layers = ENUMS.VISIBILITY.ROOM
		
		##ICONS
		var poly_icons : Array[UI_ICON] = poly.icons
		var poly_icons_3d : Array[Sprite3D] = []
		
		for p in poly_icons: ##Guaranteed only one point
			var point = UTILS.get_polygon_points_3d([p.position], data.L, data.W)
			var sprite3d = p.generate_sprite3d()
			var prop = p.get_panorama_scale()
			sprite3d.position = point[0] ##Only one point
			sprite3d.scale = Vector3.ONE/prop ##TODO FIX SCALE
			poly_icons_3d.append(sprite3d)
			sprite3d.layers = ENUMS.VISIBILITY.ROOM
		
		##TEXTS
		var poly_texts : Array[UI_TEXT3D] = poly.texts
		var poly_texts_3d : Array[Label3DFixedsize] = []
		for t in poly_texts:
			var label3d = t.generate_label3d(data.L, data.W)
			poly_texts_3d.append(label3d)
			label3d.layers = ENUMS.VISIBILITY.ROOM
		
		var dpl = DataPolygonLocation.new(poly.information, polygons_3d,
										 poly.is_door,
										poly.highlight_hover,
										poly.topic,
										 poly.door_to)
		_panorama_polygons.append(dpl)
		dpl.add_icons(poly_icons_3d)
		dpl.add_text(poly_texts_3d)

	for dpl in _panorama_polygons:		
		add_child(dpl)
		dpl.make_visible(_DEBUG) #Hide the debug shape
		dpl.pressed_door.connect(on_pressed_door_to)
	set_topic(GameState._current_topic)

func on_pressed_door_to(door_to: ROOMS.ID, _context: InteractionContext) -> void:
	var new_room =  await create_room(door_to, _north_ref)
	request_change_internal_room.emit(new_room)
	self.set_visibility(false)
	new_room.set_visibility(true)
	pass

func set_visibility(enable : bool) -> void:
	for dpl in _panorama_polygons:		
		dpl.make_interactable(enable)
		
static func create_room(room_id : ROOMS.ID, north_reference : Node3D) -> Room360:
	if not (room_id != ROOMS.ID.NONE):
		push_error("Invalid room id %s!!" % room_id)
		return null	
	var cached_room360 = Cache.retrieve_room360(room_id)
	if cached_room360: return cached_room360.with_north(north_reference) 

	var _data : PanoramaData = (await Cache.load_room(room_id)).extract()
	var room360 := Room360.new(_data).with_north(north_reference)
	Cache.store_in_cache_room360(room_id, room360)
	return room360
	
##Swaps the visibility of the polygons
func set_topic(topic : TOPICS.LAYER) -> void:
	for dpl in _panorama_polygons:
		if dpl.topic == topic:
			dpl.make_interactable(true)
		else:
			dpl.make_interactable(false)
	
func _ready() -> void:
	#visible = false
	#Displace polygons with respect to the player, so that they are centered.
	for s : Signal in signal_functions.keys():
		if not s.is_connected(signal_functions[s]):
			s.connect(signal_functions[s])
		pass

##Calcualates and sets the rotation angle for this object comparing
## the data vertical north and the global position of the north wit
## respect to (0,0,0)
func with_north(north_reference : Node3D) -> Room360:
	#Get true norths
	if not north_reference:
		push_warning("There is no north!!")
		return self
	_north_ref = north_reference
	var north_xy : Vector2 = data.north_vertical.position
	var _north_ref_2d : Vector3 = UTILS.rect_to_3d(north_xy.x, north_xy.y, data.L, data.W)
	_north_ref_2d.y = 0 #Same as setting y = middle point
	
	var _north_ref_3d : Vector3 = north_reference.global_position.normalized()
	_north_ref_3d.y = 0	

	angle_fw2 = _north_ref_2d.signed_angle_to(Vector3.FORWARD, Vector3.UP)
	angle_fw3 = _north_ref_3d.signed_angle_to(Vector3.FORWARD, Vector3.UP)	
	#Rotate	
	_angle_diff = +angle_fw2 - angle_fw3
	#self.rotation.y = _angle_diff
	return self
	
##Forces fpv to look at the direction given by the PanoramaData
func setup_fpv_entry(from : ROOMS.ID, fpv : FPV) -> void:
	#Focus sight on entry
	if from in data.entry_focus:
		var focus2 = data.entry_focus[from].position
		var focus3 = UTILS.rect_to_3d(focus2.x, focus2.y, data.L , data.W)
		focus3.y = 0 
		focus3 = focus3.rotated(Vector3.UP, _angle_diff)
		fpv.look_at(focus3, Vector3.UP) #This causes the camera to bug??
		##
		#fpv.rotate(Vector3.UP,_angle_diff)

func get_texture() -> Texture2D:
	var texture = data.texture_img
	if texture == null: 
		push_error("Texture for ", data.name_id, " not found")
	return texture
