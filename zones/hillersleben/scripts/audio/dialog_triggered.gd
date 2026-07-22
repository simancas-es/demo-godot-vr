@tool
extends Node3D

const CUTOUT_DIALOG := preload("uid://go8lcfvxa3df")
@onready var audioplayer : AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var cutout : Sprite3D = $pivot/Sprite3D
@onready var anim_player = $AnimationPlayer

@export var cutout_texture : Texture2D:
	set(value):
		cutout_texture = value
		_apply_texture()
		
		
@onready var blase_mesh : MeshInstance3D = $pivot/Sprite3D_Blase/MeshInstance3D
@onready var area_blase : Area3D = $pivot/Sprite3D_Blase/AreaClicks
@onready var svp : SubViewport = $pivot/Sprite3D_Blase/SubViewport		
signal triggered

func _ready() -> void:
	_apply_texture()
	self.add_to_group("CUTOUT_DIALOG")
	var cutouts = get_tree().get_nodes_in_group("CUTOUT_DIALOG")
	for c in cutouts: #HACK self update so that only one is active at a time
		if not c.is_connected("triggered", down):
			c.triggered.connect(down)
		if not self.is_connected("triggered", c.down):
			self.triggered.connect(c.down)
	
	#Interaction
	area_blase.detected_rc.connect(_on_detected_interaction)
	pass
## Interaction with bubble control.
func _on_detected_interaction(position, event) -> void:
	var uv = blase_mesh.geometry_instance_get_uv(position)
	var vp_pos = uv * svp.size
	var ev = event.duplicate()
	ev.position = vp_pos

	svp.push_input(ev)
	pass
	
	
func _apply_texture():
	if not is_inside_tree():
		return
	if cutout:
		cutout.texture = cutout_texture
		cutout.set_instance_shader_parameter("albedo_texture", cutout_texture)
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
	
func down() -> void:
	audioplayer.stop()
	anim_player.play(&"cutout_down")
	pass
	
func up() -> void:
	if not audioplayer.playing:
		audioplayer.play()
		anim_player.play(&"cutout_up")
	
	pass
	
