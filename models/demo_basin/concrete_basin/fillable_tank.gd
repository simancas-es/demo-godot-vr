extends Node3D
class_name FillableTank

var _current_fraction_fill : float = 0.0

@export var initial_fraction_fill : float = 0.0

@export_category("Aeration")
@export var aeration_size : float = 3.0 ##Ṛequires FillableTankAerationNodes as children
@export var initial_water_bubble_strength : float = 0.0

@onready var water_surface : MeshInstance3D = %"water surface"
@onready var animationplayer : AnimationPlayer = %AnimationPlayer

var tween_bubbles : Tween = null

signal water_bubbles_modified(strength : Array[float])

func _ready() -> void:
	var cs : Array[Vector3]
	for c in get_children():
		if c is FillableTankAerationNode: cs.append(c.position)
	set_water_bubbles_center(cs)
	
	animationplayer.animation_finished.connect(on_anim_stopped)
	fill_level(initial_fraction_fill, 0.5)
	reset_water_bubbles(initial_water_bubble_strength)
	
	queued_new_bubble_add_strengths.connect(_process_bubble_strengths_add)

##set all water bubbles to the same strength
func reset_water_bubbles(strength : float) -> void:
	var material : ShaderMaterial = water_surface.get_surface_override_material(0)
	var current_idxs = material.get_shader_parameter("flash_centers_strength")
	var shader_centers_count = current_idxs.size()
	
	var array : Array[float] = []
	array.resize(shader_centers_count) #HACK Hardcoded in the shader
	for i in range(shader_centers_count): array[i] = strength
	material.set_shader_parameter("flash_centers_strength", array)

##Gets the number of aerators. TODO: Decouple from tank. Assumes too much...
func get_water_bubble_count() -> int:
	var material : ShaderMaterial = water_surface.get_surface_override_material(0)
	var current_idxs = material.get_shader_parameter("flash_centers_strength")
	var shader_centers_count = current_idxs.size()
	return shader_centers_count

##enable or disable the centers of the water bubbling.
##It will do it by using the shader material_waterwaves_bubbles_multicenter
##First index, first center... etc as asigned in the basin.
##pass all 0.0 to disable.  Takes x seconds to do it.
##Warning!! Initialize with 1s manually.
func set_water_bubbles_strength(idxs : Array[float], time_s : float = 5.0) -> void:
	var material : ShaderMaterial = water_surface.get_surface_override_material(0)
	var current_idxs = material.get_shader_parameter("flash_centers_strength")
	var shader_centers_count = current_idxs.size()
	var idxs_resized = idxs.duplicate_deep(Resource.DEEP_DUPLICATE_ALL); idxs_resized.resize(shader_centers_count) #HACK Hardcoded in the shader
	
	
	var temp_strength : Array[float]; temp_strength.resize(shader_centers_count)
	var f = func (t):
		for i in range(shader_centers_count):
			temp_strength[i] = lerp(current_idxs[i], idxs_resized[i], t)
		material.set_shader_parameter("flash_centers_strength", temp_strength)
		
	if tween_bubbles: tween_bubbles.kill()
	tween_bubbles = create_tween()
	tween_bubbles.tween_method(f, 0.0, 1.0, time_s)

	return


#HACK Attempt at having multiple tweens queued that depend on the result of the previous tween.
class StrengthAddition:
	var strength: Array[float]
	var time_s : float
	
signal queued_new_bubble_add_strengths
var _processing_strength_additions : bool = false
var _queue_bubble_strengths : Array[StrengthAddition] = [] #queue for tweens

##Adds strength to the selected indices. This allows adding negative strength
##And adding strength from multiple sources...
func add_water_bubbles_strength(idxs : Array[float], time_s : float = 5.0) -> void:
	##BUG when more than one aerator at the same time.
	var material : ShaderMaterial = water_surface.get_surface_override_material(0)
	var current_idxs = material.get_shader_parameter("flash_centers_strength")
	var shader_centers_count = current_idxs.size()
	
	var idxs_resized = idxs.duplicate_deep(Resource.DEEP_DUPLICATE_ALL); idxs_resized.resize(shader_centers_count) #HACK Hardcoded in the shader
	var sa : StrengthAddition = StrengthAddition.new()
	sa.strength = idxs_resized
	sa.time_s = time_s
	_queue_bubble_strengths.append(sa)
	queued_new_bubble_add_strengths.emit()

##BUG when setting in the middle of it?
func _process_bubble_strengths_add() -> void:
	if _queue_bubble_strengths.size() == 0:
		_processing_strength_additions = false
		return##BUG 
	if _processing_strength_additions : return ##Tween active at the moment
	_processing_strength_additions = true
	var sa : StrengthAddition = _queue_bubble_strengths.pop_front() ##fifo
	
	var material : ShaderMaterial = water_surface.get_surface_override_material(0)
	var current_idxs = material.get_shader_parameter("flash_centers_strength")
	var count = current_idxs.size()
	for i in range(count):
		sa.strength[i] = clampf(sa.strength[i] + current_idxs[i], 0.0, 1.0)
	
	var temp_strength : Array[float]; temp_strength.resize(count)
	var f = func (t):
		for i in range(count):
			temp_strength[i] = lerp(current_idxs[i], sa.strength[i], t)
		material.set_shader_parameter("flash_centers_strength", temp_strength)
	
	tween_bubbles = create_tween()
	tween_bubbles.tween_method(f, 0.0, 1.0, sa.time_s)
	await tween_bubbles.finished
	_processing_strength_additions = false
	queued_new_bubble_add_strengths.emit()
	
	return

##Sets the LOCAL centers of the aerators on the horizontal plane (only xz coordinates are used)
func set_water_bubbles_center(centers : Array[Vector3]) -> void:
	if centers.size() >8: push_error("Maximum amount of centers is 8!!"); return
	var material : ShaderMaterial = water_surface.get_surface_override_material(0)
	var _size = centers.size()
	material.set_shader_parameter("flash_center_count", _size )
	assert (material.get_shader_parameter("flash_center_count") == centers.size())
	
	var centers_resized = centers.duplicate_deep(Resource.DEEP_DUPLICATE_ALL); centers_resized.resize(_size)
	material.set_shader_parameter("flash_centers", centers_resized)
	
	assert(material.get_shader_parameter("flash_centers") == centers_resized)
	return
	

#TODO. HACK. Animations shouldn't be sped up like this but this works for specific geometries.
##Fill the tank to fraction [0.0 - 1.0] in so many seconds.
##Only use this for geometry, not for actual animations with seconds.
func fill_level(fraction : float, time_s : float) -> void:
	fraction = clampf(fraction, 0.0, 1.0)
	if fraction == _current_fraction_fill: return
	
	animationplayer.pause()
	var anim = animationplayer.get_animation("level_low_to_full")
	anim.track_set_interpolation_type(0, Animation.INTERPOLATION_LINEAR)
	var total_length = anim.length
	
	var current_fraction = _current_fraction_fill
	
	var base_timescale = 1.0 / total_length ##Fractions of anim per second
	var desired_timescale = abs(fraction - current_fraction)/time_s ##Fractions of anim per second
	var time_factor = desired_timescale / base_timescale
	
	 
	var backwards : bool = fraction < current_fraction	
	#animationplayer.speed_scale = time_factor	
	var speed
	if backwards: speed = -time_factor
	else: speed = time_factor
	
	if not backwards:
		animationplayer.play_section("level_low_to_full",
									current_fraction * total_length, fraction * total_length,
									-1,
									speed,
									false)
	else:
		animationplayer.play_section("level_low_to_full",
									fraction * total_length, current_fraction * total_length,
									-1,
									speed,
									true)

	set_process(true)


func on_anim_stopped(anim_name : String) -> void:
	if anim_name != "level_low_to_full": 
		return
	var pos = animationplayer.current_animation_position
	var tl = animationplayer.current_animation_length
	var fr = pos/tl
	_current_fraction_fill = fr
	set_process(false)

##Updates the internal fraction value
func _update_fraction() -> void:
	if animationplayer.current_animation == "level_low_to_full":
		_current_fraction_fill = animationplayer.current_animation_position / animationplayer.current_animation_length

func _process(delta: float) -> void:
	_update_fraction()
