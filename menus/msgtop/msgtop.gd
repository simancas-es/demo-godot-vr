extends Control
class_name UI_MSGTOP
#
#const base_text = "DEFAULT_MSGTOP" #NO_TRANSLATE
#const base_DISPLAY_DURATION := 5.0

var text = "DEFAULT_MSGTOP" #NO_TRANSLATE
var DISPLAY_DURATION := 10.0

@onready var label: Label = %Label
var shader_material: ShaderMaterial

var amplitude : float
var frequency : float
var speed : float
var zorder : float
#
#static func with(text_ : String = base_text, duration_s : float = base_DISPLAY_DURATION,
			#amplitude : float = 40.0, frequency : float = 1.0, speed : float = 2.0,
			#zorder : float = -1) -> UI_MSGTOP:
	#var msgtop = UI_MSGTOP.new(text_, duration_s, amplitude, frequency, speed, zorder)
	#return msgtop
			

func with(text_ : String = text, duration_s : float = DISPLAY_DURATION,
			_amplitude : float = 40.0, _frequency : float = 1.0, _speed : float = 2.0,
			_zorder : float = -1
			) -> UI_MSGTOP:
	text = text_
	DISPLAY_DURATION = duration_s
	
	# Setup z_index to be under other UI
	zorder = _zorder
	amplitude = _amplitude
	frequency = _frequency
	speed = _speed
	
	return self

func _ready() -> void:
		# Create Label with text
	label.text = text
	if label == null :
		label = Label.new()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		label.anchor_left = 0.5
		label.anchor_right = 0.5
	
	label.pivot_offset = label.get_minimum_size() / 2 #HACK

	# Create shader and apply it to the Label
	var shader := Shader.new()
	var code : Resource = await Cache.load_asynchronous(RESOURCES.SHADER_WAVYTEXT, get_tree())
	shader.code = code.code  # TODO: Magic from .gdshader
	shader_material = ShaderMaterial.new()
	shader_material.shader = shader
	shader_material.set("amplitude", amplitude)
	shader_material.set("frequency", frequency)
	shader_material.set("speed", speed)
	label.material = shader_material

	# Update shader time via process
	set_process(true)

	
	# Show and start timer
	show()
	await get_tree().create_timer(DISPLAY_DURATION).timeout
	queue_free()
	
func _process(delta: float) -> void:
	if shader_material:
		shader_material.set("time", Time.get_ticks_msec() / 1000.0)
		
