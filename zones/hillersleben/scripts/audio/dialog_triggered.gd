@tool
extends Node3D


@export var cutout_texture : Texture2D:
	set(value):
		cutout_texture = value
		_apply_texture()
@export_multiline var description_text: String:
	set(value):
		description_text = value
		_apply_text()
@export var audiostream : AudioStream:
	set(value):
		audiostream = value
		_apply_audio()
	
@export var ok_disables : bool = true
	
const CUTOUT_DIALOG := preload("uid://go8lcfvxa3df")
@onready var audioplayer : AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var cutout : Sprite3D = $pivot/Sprite3D
@onready var anim_player = $AnimationPlayer

const DIALOGUI := preload("uid://cf711ixjimsdh")
const AREABLASE := preload("uid://o1i31andmimk")
@onready var blase_mesh : MeshInstance3D = $pivot/Sprite3D_Blase/MeshInstance3D
@onready var area_blase : AREABLASE = $pivot/Sprite3D_Blase/MeshInstance3D/AreaClicks
@onready var svp : SubViewport = $pivot/Sprite3D_Blase/SubViewport	
@onready var control : DIALOGUI = $pivot/Sprite3D_Blase/SubViewport/Control
signal triggered

var disabled : bool = false
enum STATE {DOWN, UP}
var state = STATE.DOWN 

func _ready() -> void:
	_apply_texture()
	_apply_text()
	_apply_audio()
	if Engine.is_editor_hint():
		return
	self.add_to_group("CUTOUT_DIALOG")
	var cutouts = get_tree().get_nodes_in_group("CUTOUT_DIALOG")
	for c in cutouts: #HACK self update so that only one is active at a time
		if c == self: continue
		if not c.is_connected("triggered", down):
			c.triggered.connect(down)
		if not self.is_connected("triggered", c.down):
			self.triggered.connect(c.down)
	
	#Interaction
	area_blase.detected_rc.connect(_on_detected_interaction)
	
	set_control(control)
	pass

func set_control(controlx : DIALOGUI) -> void:
	if controlx == null:
		push_warning("Missing control...")
		return
	control = controlx
	controlx.ok.connect(_on_ok)
	controlx.repeat.connect(_on_repeat)
	pass
	
## Interaction with bubble control.
func _on_detected_interaction(position, event) -> void:
	if position == null:
		var exit_event = InputEventMouseMotion.new()
		exit_event.position = Vector2(-1, -1)
		svp.push_input(exit_event)
		return

	var local = blase_mesh.to_local(position)
	var plane_size = blase_mesh.mesh.size

	var uv = Vector2(
		(local.x / plane_size.x) + 0.5,
		0.5 - (local.y / plane_size.y)
	)

	var vp_pos = uv * Vector2(svp.size)

	var ev = event.duplicate()
	ev.position = vp_pos

	svp.push_input(ev)
	
	
func _apply_texture():
	if not is_inside_tree():
		return
	if cutout:
		cutout.texture = cutout_texture
		var mat : ShaderMaterial = cutout.material_override
		mat.set_shader_parameter("albedo_texture", cutout_texture)
		
		set_sprite_height(cutout, 200)
		
func set_sprite_height(sprite: Sprite3D, target_height_px: float = 200.0):
	if not sprite.texture:
		return
	
	var tex_height = sprite.texture.get_height()
	if tex_height == 0:
		return
	
	var scale_factor = target_height_px / tex_height	
	sprite.scale = Vector3(scale_factor, scale_factor, scale_factor)
	sprite.offset.x = -sprite.texture.get_width()/2

func _apply_text() -> void:
	if not is_inside_tree():
		return
	control.set_text(tr(description_text))
	pass

func _apply_audio() -> void:
	if not is_inside_tree():
		return
	audioplayer.stream = audiostream
	

func down() -> void:
	if state == STATE.DOWN : return
	audioplayer.stop()
	anim_player.play(&"cutout_down")
	if (area_blase != null) and (not area_blase.is_queued_for_deletion()): area_blase.set_deferred("monitorable", false)
	state = STATE.DOWN

	pass
	
func up() -> void:
	if state == STATE.UP : return
	if disabled : return
	if not audioplayer.playing:
		audioplayer.play()
		anim_player.play(&"cutout_up")
	if (area_blase != null) and (not area_blase.is_queued_for_deletion()):  area_blase.set_deferred("monitorable", true)
	triggered.emit()
	state = STATE.UP
	pass

func _on_ok() -> void:
	if ok_disables: disabled = true
	down()
	
func _on_repeat() -> void:
	audioplayer.play()
	

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		if not is_node_ready():	return
		_apply_audio()
		_apply_text() 
		if audioplayer.playing: audioplayer.stop(); audioplayer.play()
