class_name DataPolygonLocation extends Node3D

#Panorama polygons that react to the mouse.
signal pressed_door(door_to : ROOMS.ID, il : FPVInteractionLogic)

#var coor_spherical : Array[Vector3]
var info : Dictionary ## locale/hint,title,bbcode_text
var interactive_panels : Array[InteractivePanel]
var activatable : bool = true

var is_door : bool #Whether this interactive panel should serve as a door
var door_to : ROOMS.ID = 0
var highlight_hover : bool = false

var topic : TOPICS.LAYER = TOPICS.LAYER.ABWASSER

var icons : Array[Sprite3D] = []
var labels : Array[Label3D] = []

#Strings
const _read_text = "Read [{key}]"
#var _DEBUG = false

func _init(
		 #coor_spherical_ : Array[Vector3],
		original_info_ : Dictionary,
		interactive_panels_ : Array[InteractivePanel],
		is_door_ : bool,
		highlight_hover_ : bool,
		topic_ : TOPICS.LAYER,
		door_to_ : ROOMS.ID = 0,
		):
	#self.coor_spherical = coor_spherical_
	info = original_info_
	interactive_panels = interactive_panels_
	is_door = is_door_
	door_to = door_to_
	highlight_hover = highlight_hover_
	topic = topic_
	
	activatable = true

func _ready() -> void:
	for ip : InteractivePanel in interactive_panels:
		add_child(ip)
		ip.looked_at.connect(on_looked_at)
		ip.dropped_looked_at.connect(on_dropped_lookedat)
		#Whenever we activate one of the interactive panels
		ip.activated.connect(on_activated)
		ip.collision_layer = ENUMS.COLLISION_LAYER.ROOM
		ip.collision_mask  = 0
	

##Hint_text is defined in the .json files and is something like
##"You are looking at X". After that there is an addition of a command like:
## \n Read [E] with the interacting key. This is not defined in the json for objects in this class.
func populate_hint_text(locale : String) -> void:
	if not (locale in info): locale = "en"
	if not (locale in info):
		push_error("Something wrong with PanoramaPolygons!! info is empty! %s" %self)
		return
	for ip in interactive_panels:
		ip.hint_text[ENUMS.ACTION.INTERACT] = info[locale]["hint"] + "\n" + tr(_read_text) 
	pass
##Adds icons to the polygon
func add_icons(icons_ : Array[Sprite3D]) -> void:
	for icon in icons_:
		icons.append(icon)
		add_child(icon)
		icon.visible = true
	pass

func add_text(label3d_ : Array[Label3DFixedsize]) -> void:
	for l in label3d_:
		labels.append(l)
		add_child(l)
		l.visible = true

##Makes ip neither interactable nor visible
func make_interactable(enable : bool) -> void:
	var collision_layer = ENUMS.COLLISION_LAYER.ROOM
	#var visibility_layer = ENUMS.VISIBILITY.ROOM
	if not enable: collision_layer = ENUMS.COLLISION_LAYER.NONE
	#if not enable: visibility_layer = ENUMS.VISIBILITY.NONE
	
	##Disable IPs
	for ip in interactive_panels:
		ip.monitorable = enable ##Raycasts detect this anyways
		#ip.disable_mode = mode
		ip.collision_layer =  collision_layer
		#ip.visible_mesh.layer = visibility_layer
	
	##Hide related icons with an animation	
	var tweens = []
	if icons.size() == 0 : return
	for icon in icons:
		var tween = create_tween()
		tweens.append(tween)
		if enable:
			icon.modulate = Color.TRANSPARENT
			tween.tween_property(icon, "modulate", Color.WHITE, 0.1)
			##TODO Possible bug if swapping fast
		else:
			icon.modulate = Color.WHITE
			tween.tween_property(icon, "modulate", Color.TRANSPARENT, 0.1)
			##TODO Possible bug if swapping fast
	await tweens[tweens.size()-1].finished
	
## Make all interactive panels visible when hovered and _lookedat
func make_visible(enable : bool) -> void:
	for ip in interactive_panels:
		ip.set_visible(enable and highlight_hover)

		
func on_looked_at(_origin : Node, _il : FPVInteractionLogic):
	make_visible(true)
	pass	

func on_dropped_lookedat():
	make_visible(false)

	pass

func on_activated(_origin : Node, _il : FPVInteractionLogic):
	if !activatable : return
	
	#Populate info menu
	if !is_door:
		var popup : InfoPopup = load(RESOURCES.MENU_POPUP).instantiate() #No instanciar clase
		var locale = TranslationServer.get_locale()
		if not (locale in info) : locale = "en"
		var title = info[locale]["title"]
		var bbcode_text = info[locale]["bbcode_text"]
		popup.init(title, bbcode_text )
		Signals.popup_text.emit(popup)

		
	#If a door has been activated then change rooms
	if is_door:
		if door_to in ROOMS.ID.values():
			#Signals.request_change_room.emit(door_to) #DE
			pressed_door.emit(door_to, _il)
	
	pass
	
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("lock_movement"):
		make_visible(false)


##Listen to changes in the locale
func _notification(what):
	if what == NOTIFICATION_TRANSLATION_CHANGED :
		populate_hint_text(TranslationServer.get_locale())
