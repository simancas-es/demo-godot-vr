extends Panel
class_name EnvSelectorMapPanel
var _DEBUG : bool = false


@onready var debuglabel : Label = $DebugCoords
@onready var maptexture : TextureRect = %MapTexture
@onready var progressbar : TextureProgressBar = %TextureProgressBar
@onready var van : Sprite2D = %Van

@export var transition_van_fadein_s = 0.5
@export var transition_van_fadeout_s = 0.5
@export var transition_van_s = 3.0


##Coordinates within the map
@export var leftlong : float ##Leftmost coordinate in the map, degrees
@export var rightlong : float ##Rightmost coordinate in the map, degrees
@export var toplat : float ##Topmost coordinate in the map, degrees
@export var botlat : float ##Bottommost coordinate in the map, degrees

var latdif : float
var longdif : float

var starting_pos : Control = null
var target_pos : Control = null

var current_olat_olong : Vector2
var current_tlat_tlong : Vector2

#var anchors_default_left : float
#var anchors_default_top : float
#var anchors_default_right : float
#var anchors_default_bottom : float
var default_mt_position : Vector2
var default_mt_pivot : Vector2

func _ready() -> void:
	#anchors_default_left = self.anchor_left
	#anchors_default_left = self.anchor_top
	#anchors_default_left = self.anchor_right
	#anchors_default_left = self.anchor_bottom
	#
	#default_mt_position = maptexture.position
	#default_mt_pivot = maptexture.pivot_offset
	
	latdif = toplat - botlat
	longdif = rightlong - leftlong
	
	self.resized.connect(on_resize_adjust)
	van.modulate = Color.TRANSPARENT


func on_resize_adjust() -> void:
	if current_olat_olong != null:
		generate_starting_position(current_olat_olong.x, current_olat_olong.y)
		
	if current_tlat_tlong != null:
		generate_target_position(current_tlat_tlong.x, current_tlat_tlong.y)
	pass

##Resets starting and finishing positions and the map pivot and offset
func reset() -> void:
	if starting_pos in maptexture.get_children():
		maptexture.remove_child(starting_pos)
	if starting_pos != null:
		starting_pos.queue_free()
	starting_pos = null
	
	if target_pos in maptexture.get_children():
		maptexture.remove_child(target_pos)
	if target_pos != null:
		target_pos.queue_free()
	target_pos = null

	await reset_map()
	pass

##Tweens and resets all  constraints.
func reset_map() -> void:
	#print("Resetting map...")
	var tween : Tween = create_tween()
	tween.set_parallel()
	tween.tween_property(maptexture, "pivot_offset", default_mt_pivot , 1.0).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(maptexture, "scale", Vector2(1, 1), 1.0).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(maptexture, "position", default_mt_position, 1.0).set_trans(Tween.TRANS_LINEAR)
	
	await tween.finished
	
	pass
	
		
##Percentage of latitude and longitude from the bottom and from the left respectively
##x is latitude, y is longitude
func calculate_pct(lat : float, long : float) -> Vector2:
	return Vector2((lat - botlat) / latdif ,( long - leftlong )/ longdif)
	
##Puts a pin on the original coordinates.
func generate_starting_position(olat : float, olong : float, _animate = false) -> void:
	current_olat_olong = Vector2(olat, olong)

#TODO Animate
	if starting_pos != null:
		starting_pos.queue_free()
		maptexture.remove_child(starting_pos)
	
	var pos_pct = calculate_pct(olat, olong)
	var px : Rect2 = maptexture.get_rect()
	
	var posx = px.size.x * pos_pct.y
	var posy = px.size.y * (1 - pos_pct.x)
	
	#print("O Coordinates : %s, %s" % [posx, posy])

	var label = Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.position = Vector2(posx, posy)
	label.text = "O" # NO_TRANSLATE
	
	starting_pos = label	
	#TODO Animate
	maptexture.add_child(starting_pos)
	#print("Generating starting pos label at %s, %s" % [posx, posy])
	
	pass

func generate_target_position(tlat : float, tlong : float, _animate = false) -> void:
	current_tlat_tlong = Vector2(tlat, tlong)
	#TODO Animate
	if target_pos != null:
		target_pos.queue_free()
		maptexture.remove_child(target_pos)
	
	var pos_pct = calculate_pct(tlat, tlong)
	var px : Rect2 = maptexture.get_rect()
	
	var posx = px.size.x * pos_pct.y
	var posy = px.size.y * (1 - pos_pct.x)
	
	#print("X Coordinates : %s, %s" % [posx, posy])
	var label = Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.position = Vector2(posx, posy)
	label.text = "X" # NO_TRANSLATE
	
	target_pos = label	
	#TODO Animate
	maptexture.add_child(target_pos)
	#print("Generating target pos label at %s, %s" % [posx, posy])
	
	pass


##Generates the objects for the animation of starting X and end X for adventure
func generate_anim(olat : float, olong : float, tlat: float, tlong : float) -> void:
	#Calculate positions on map
	if _DEBUG:
		print("Generating map animation...")	
	if starting_pos == null:
		generate_starting_position(olat, olong)
	generate_target_position(tlat, tlong)
	return

##Animates progress after being zoomed in
func animate_loading_screen():
	#Play animation on loop.
	#print("Animating loading screen from Map Panel")
	var sp : Vector2 = starting_pos.get_rect().get_center() #a Control
	var tp : Vector2 = target_pos.get_rect().get_center()
	
	#Now rotate it and flip it
	#van.flip_h = true
	if tp.x > sp.x:
		van.flip_v = true
		van.offset = Vector2(-77, -9.5)
	else:
		van.flip_v = false
		van.offset = Vector2(-78, -198)
		
	var angle = sp.angle_to_point(tp) + PI ##Angle with x axis, up = 90º
	van.rotation = angle	
	van.position = sp
	
	#Make it appear
	var tween = create_tween()
	van.modulate = Color.TRANSPARENT
	tween.tween_property(van, "modulate", Color.WHITE, transition_van_fadein_s)
	await tween.finished

	
	
	var tweenpos = create_tween()
	tweenpos.tween_property(van, "position", tp, transition_van_s)
	await tweenpos.finished
	
	tween = create_tween()
	tween.tween_property(van, "modulate", Color.TRANSPARENT, transition_van_fadeout_s)
	await tween.finished
	
	
	pass


##Changes pivot and scales it up...
func zoom_pivot(olat : float, olong : float, tlat : float, tlong : float, margin : float = 0.2) -> void:
	#Map geom
	var geom : Rect2 = maptexture.get_rect()
	#Note. -1 anchor means -100% parent width/height
	var w : float = geom.size.x
	var h : float = geom.size.y
	var L : float = geom.size.y #Assuming it fits vertically
	var W : float = (geom.position.x + w/2)/ maptexture.anchor_left ##Assuming centered at 0.5...

	var leftmost : float = min(olong, tlong)
	var rightmost : float = max(olong, tlong)
	var topmost : float = max(olat, tlat)
	var bottommost : float = min(olat, tlat)
	
	var points_long_diff : float = rightmost - leftmost ##This is 1 - 2xmargin as a fraction
	var long_margin : float = points_long_diff/(1 - 2*margin) * margin
	var margin_pos_left : float = leftmost - long_margin
	var margin_pos_right : float = rightmost + long_margin
	
	var points_lat_diff : float = topmost - bottommost
	var lat_margin : float = points_lat_diff/(1 - 2*margin) * margin
	var margin_pos_top : float = topmost + lat_margin
	var margin_pos_bottom : float = bottommost - lat_margin
	
	#in degrees
	var midpoint_horizontal : float = margin_pos_left/2 + margin_pos_right/2
	var midpoint_vertical : float = margin_pos_top/2 + margin_pos_bottom/2
	var pct_midpoint : Vector2 = calculate_pct(midpoint_vertical, midpoint_horizontal)
	
	#Scaling how much.
	var total_longitudinal : float = max(margin_pos_right - margin_pos_left, 1 )
	var total_vertical : float = max(margin_pos_top - margin_pos_bottom, 1)
	
	var zoom_square_x : float = total_longitudinal/longdif * w #px
	var zoom_square_y : float = total_vertical/latdif * h
	var sc : float = W / zoom_square_x
	if sc * zoom_square_y > L:
		sc = L/zoom_square_y
		
	var pivotx : float = pct_midpoint.y * w
	var pivoty : float = (1 - pct_midpoint.x)* h
	var position2x: float = maptexture.position.x - (pivotx - w/2)
	var position2y: float = maptexture.position.y - (pivoty - h/2)


	default_mt_pivot = maptexture.pivot_offset
	default_mt_position = maptexture.position
	
	var tween : Tween = create_tween()
	tween.tween_property(maptexture, "position", Vector2(position2x, position2y), 0.5).set_trans(Tween.TRANS_LINEAR)
	tween.chain()
	#tween.set_parallel()	
	tween.tween_property(maptexture, "pivot_offset", Vector2(pivotx, pivoty) , 0.5).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(maptexture, "scale", Vector2(sc, sc), 2.0).set_trans(Tween.TRANS_LINEAR)
	

	
	await tween.finished
	#maptexture.pivot_offset = Vector2(pct_midpoint.y * w, pct_midpoint.x * h)
	#maptexture.scale = Vector2(sc, sc)
	
	
	pass
	
	
	
#DEBUG
#func _unhandled_key_input(event: InputEvent) -> void:
	#if Input.is_action_just_pressed("interact"):
		#generate_anim(51.5, 11.5, 52.9, 12.5)
		#await zoom_pivot(51.5, 11.5, 52.9, 12.5, 0.2)
		##
		#animate_loading_screen()
		##
	#if Input.is_action_just_pressed("uidebug"):
		#reset()
	#
	#pass
