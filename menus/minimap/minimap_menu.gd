extends Control

const ZoneMinimap := preload("res://clases/zones/zone_minimap.gd")

@export var player_icon_texture: Texture2D = null

@onready var _map_image: TextureRect = %MapImage
@onready var _player_image: TextureRect = %PlayerImage

var _zone_minimap: ZoneMinimap = null
var _active_fpv: Node3D = null
var _last_map_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	visible = false
	set_process(false)
	_ensure_player_icon_texture()
	_player_image.texture = player_icon_texture

func show_for(zone_minimap: ZoneMinimap, active_fpv: Node3D) -> void:
	_zone_minimap = zone_minimap
	_active_fpv = active_fpv
	_sync_map_texture()
	visible = true
	set_process(true)
	update_map_offset()

func close() -> void:
	visible = false
	set_process(false)
	_zone_minimap = null
	_active_fpv = null

func is_open() -> bool:
	return visible

func update_map_offset() -> bool:
	if _zone_minimap == null or _active_fpv == null:
		return false
	if not is_instance_valid(_zone_minimap) or not is_instance_valid(_active_fpv):
		return false
	if not _zone_minimap.is_projection_available():
		return false
	var active_position: Vector3 = _active_fpv.global_position if _active_fpv.is_inside_tree() else _active_fpv.position
	var projected_position: Vector2 = _zone_minimap.world_to_map_position(active_position)
	var viewport_size: Vector2 = get_viewport_rect().size
	if viewport_size == Vector2.ZERO:
		viewport_size = size
	var center: Vector2 = viewport_size * 0.5
	_last_map_offset = center - projected_position
	_map_image.position = _last_map_offset
	_player_image.position = center - (_player_image.size * 0.5)
	return true

func get_last_map_offset() -> Vector2:
	return _last_map_offset

func get_active_minimap() -> ZoneMinimap:
	return _zone_minimap

func _process(_delta: float) -> void:
	update_map_offset()

func _sync_map_texture() -> void:
	if _zone_minimap == null or _zone_minimap.map_texture == null:
		_map_image.texture = null
		return
	_map_image.texture = _zone_minimap.map_texture
	var texture_size: Vector2 = _zone_minimap.map_texture.get_size()
	_map_image.custom_minimum_size = texture_size
	_map_image.size = texture_size

func _ensure_player_icon_texture() -> void:
	if player_icon_texture != null:
		return
	var image: Image = Image.create(24, 24, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.0, 0.85, 1.0, 1.0))
	player_icon_texture = ImageTexture.create_from_image(image)
