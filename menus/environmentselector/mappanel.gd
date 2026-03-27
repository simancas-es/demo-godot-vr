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
func zoom_pivot(olat: float, olong: float, tlat: float, tlong: float, margin: float = 0.2) -> void:
	# --- 1. Compute map geometry ---
	var geom: Rect2 = maptexture.get_rect()
	var w = geom.size.x
	var h = geom.size.y
	var L = h
	var W = (geom.position.x + w/2) / maptexture.anchor_left

	# --- 2. Compute bounds with margin ---
	var leftmost = min(olong, tlong)
	var rightmost = max(olong, tlong)
	var topmost = max(olat, tlat)
	var bottommost = min(olat, tlat)

	var points_long_diff = rightmost - leftmost
	var long_margin = points_long_diff / (1 - 2*margin) * margin
	var margin_pos_left = leftmost - long_margin
	var margin_pos_right = rightmost + long_margin

	var points_lat_diff = topmost - bottommost
	var lat_margin = points_lat_diff / (1 - 2*margin) * margin
	var margin_pos_top = topmost + lat_margin
	var margin_pos_bottom = bottommost - lat_margin

	# --- 3. Midpoint in percent ---
	var midpoint_horizontal = (margin_pos_left + margin_pos_right) / 2
	var midpoint_vertical = (margin_pos_top + margin_pos_bottom) / 2
	var pct_midpoint = calculate_pct(midpoint_vertical, midpoint_horizontal)

	# --- 4. Compute scale ---
	var total_longitudinal = max(margin_pos_right - margin_pos_left, 1)
	var total_vertical = max(margin_pos_top - margin_pos_bottom, 1)

	var zoom_square_x = total_longitudinal / longdif * w
	var zoom_square_y = total_vertical / latdif * h
	var sc = W / zoom_square_x
	if sc * zoom_square_y > L:
		sc = L / zoom_square_y

	# --- 5. Compute new pivot and position ---
	var pivotx = pct_midpoint.y * w
	var pivoty = (1 - pct_midpoint.x) * h
	var position2x = maptexture.position.x - (pivotx - w/2)
	var position2y = maptexture.position.y - (pivoty - h/2)

	# --- 6. Store default map info ---
	default_mt_pivot = maptexture.pivot_offset
	default_mt_position = maptexture.position
	var default_mt_scale = maptexture.scale

	# --- 7. Compute label offsets relative to pivot & scale ---
	var label_offsets = []
	for label in maptexture.get_children():
		# Store relative offset from pivot in normalized coordinates
		var offset = (label.position - maptexture.pivot_offset) / maptexture.scale
		label_offsets.append({"node": label, "offset": offset})

	# --- 8. Create Tween ---
	var tween: Tween = create_tween()
	tween.tween_property(maptexture, "position", Vector2(position2x, position2y), 0.5).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(maptexture, "pivot_offset", Vector2(pivotx, pivoty), 0.5).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(maptexture, "scale", Vector2(sc, sc), 2.0).set_trans(Tween.TRANS_LINEAR)

	# --- 9. Tween labels positions to match pivot & scale ---
	for entry in label_offsets:
		var label = entry["node"]
		var offset = entry["offset"]
		# Compute target position after pivot & scale change
		var target_pos = Vector2(
			pivotx + offset.x * sc,
			pivoty + offset.y * sc
		)
		tween.tween_property(label, "position", target_pos, 2.0).set_trans(Tween.TRANS_LINEAR)
	
	
	
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
