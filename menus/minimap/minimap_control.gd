extends Control

const MinimapController := preload("res://systems/system-minimap/minimap_controller.gd")
const MinimapMarkerState := preload("res://systems/system-minimap/minimap_marker_state.gd")

@export var player_icon_texture: Texture2D = null

@onready var _map_image: TextureRect = %MapImage
@onready var _player_image: TextureRect = %PlayerImage

var _controller: MinimapController = null
var _last_map_offset: Vector2 = Vector2.ZERO
var _marker_images: Array[TextureRect] = []

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	set_process(false)
	_ensure_player_icon_texture()
	_player_image.texture = player_icon_texture
	_player_image.visible = false
	_marker_images.append(_player_image)

func show_for(controller: MinimapController) -> bool:
	_controller = controller
	_sync_map_texture()
	set_process(true)
	return update_map_offset()

func clear() -> void:
	set_process(false)
	_controller = null
	_hide_marker_images()

func update_map_offset() -> bool:
	if _controller == null:
		return false
	if not _controller.refresh():
		return false
	return _apply_controller_state()

func get_last_map_offset() -> Vector2:
	return _last_map_offset

func get_active_controller() -> MinimapController:
	return _controller

func _process(delta: float) -> void:
	if _controller == null:
		return
	if _controller.tick(delta):
		_apply_controller_state()

func _apply_controller_state() -> bool:
	var viewport_size: Vector2 = get_viewport_rect().size
	if viewport_size == Vector2.ZERO:
		viewport_size = size
	var center: Vector2 = viewport_size * 0.5
	_last_map_offset = center - _controller.get_center_map_position()
	_map_image.position = _last_map_offset
	_sync_marker_images()
	return true

func _sync_map_texture() -> void:
	if _controller == null or _controller.get_map_texture() == null:
		_map_image.texture = null
		return
	var map_texture: Texture2D = _controller.get_map_texture()
	_map_image.texture = map_texture
	var texture_size: Vector2 = map_texture.get_size()
	_map_image.custom_minimum_size = texture_size
	_map_image.size = texture_size

func _ensure_player_icon_texture() -> void:
	if player_icon_texture != null:
		return
	var image: Image = Image.create(24, 24, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.0, 0.85, 1.0, 1.0))
	player_icon_texture = ImageTexture.create_from_image(image)

func _sync_marker_images() -> void:
	if _controller == null:
		_hide_marker_images()
		return
	var marker_states: Array[MinimapMarkerState] = _controller.get_visible_marker_states()
	_ensure_marker_image_count(marker_states.size())
	for index: int in range(marker_states.size()):
		var marker_state: MinimapMarkerState = marker_states[index]
		var marker_image: TextureRect = _marker_images[index]
		marker_image.visible = true
		marker_image.texture = marker_state.marker_texture if marker_state.marker_texture != null else player_icon_texture
		marker_image.modulate = marker_state.marker_color
		marker_image.custom_minimum_size = Vector2(24.0, 24.0)
		marker_image.size = Vector2(24.0, 24.0)
		marker_image.position = _last_map_offset + marker_state.map_position - (marker_image.size * 0.5)
	for index: int in range(marker_states.size(), _marker_images.size()):
		_marker_images[index].visible = false

func _ensure_marker_image_count(count: int) -> void:
	while _marker_images.size() < count:
		var marker_image: TextureRect = TextureRect.new()
		marker_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
		marker_image.custom_minimum_size = Vector2(24.0, 24.0)
		marker_image.size = Vector2(24.0, 24.0)
		add_child(marker_image)
		_marker_images.append(marker_image)

func _hide_marker_images() -> void:
	for marker_image: TextureRect in _marker_images:
		marker_image.visible = false
