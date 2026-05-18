@tool
extends Area3D

@export var disappear_on_enter: bool = true
@export var locator_id: SYSTEMTASKSSETTINGS.LOCATOR_ID

@onready var locator : SYSTEMTASKS_UIDCLASSREF.SystemTasksLocator = SYSTEMTASKS_UIDCLASSREF.SystemTasksLocator.new(locator_id)

# Pulsation
@export var pulsate: bool = false:
	set(value):
		pulsate = value
		_update_process_state()
@export_range(0.1, 10.0, 0.1) var pulse_time_s: float = 2.0

# CHANGE COLOR
@export var color: Color = Color.WHITE:
	set(value):
		color = value
		_apply_color.call_deferred()
var _time: float = 0.0 #internal for color pulsation.


@onready var mesh: MeshInstance3D = $MeshInstance3D


func _enter_tree() -> void:
	_update_process_state()
	_apply_color()

func _init() -> void:
	monitoring = false
	visible = false
	
func _ready() -> void:
	add_child(locator)
	if disappear_on_enter:
		body_entered.connect(_on_body_entered)

func _on_body_entered(_body) -> void:
	queue_free()


func activate() -> void:
	visible = true
	monitoring = true
	set_process(true)

func _process(delta: float) -> void:
	if not pulsate:
		return

	var mat := _get_material()
	if mat == null:
		return

	_time += delta

	var alpha := (sin(_time * (TAU / pulse_time_s)) + 1.0) * 0.5

	mat.set_shader_parameter("alpha", alpha)


func _get_material() -> ShaderMaterial:
	if mesh == null:
		return null

	var m = mesh.material_override

	if m == null:
		m = mesh.get_active_material(0)

	if m is ShaderMaterial:
		return m

	return null


func _apply_color() -> void:
	var mat := _get_material()
	if mat == null:
		return
	mat.set_shader_parameter("tint_color", color)

func _update_process_state() -> void:
	if Engine.is_editor_hint():
		set_process(pulsate)
	else:
		set_process(pulsate and visible)
