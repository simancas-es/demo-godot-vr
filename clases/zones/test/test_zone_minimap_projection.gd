extends GutTest

const ZoneMinimap := preload("res://clases/zones/zone_minimap.gd")

var _anchor_a: Node3D = null
var _anchor_b: Node3D = null
var _minimap: ZoneMinimap = null

func before_each() -> void:
	_anchor_a = add_child_autoqfree(Node3D.new())
	_anchor_b = add_child_autoqfree(Node3D.new())
	_minimap = add_child_autoqfree(ZoneMinimap.new())
	_anchor_a.global_position = Vector3(10.0, 0.0, -4.0)
	_anchor_b.global_position = Vector3(20.0, 0.0, 6.0)
	_minimap.world_anchor_a = _anchor_a
	_minimap.world_anchor_b = _anchor_b
	_minimap.map_texture = _make_texture()
	_minimap.map_anchor_a_pixels = Vector2(100.0, 50.0)
	_minimap.map_anchor_b_pixels = Vector2(120.0, 70.0)

func after_each() -> void:
	_minimap = null
	_anchor_a = null
	_anchor_b = null

func test_anchor_a_maps_to_map_anchor_a_pixels() -> void:
	assert_eq(_minimap.world_to_map_position(Vector3(10.0, 99.0, -4.0)), Vector2(100.0, 50.0))

func test_anchor_b_maps_to_map_anchor_b_pixels() -> void:
	assert_eq(_minimap.world_to_map_position(Vector3(20.0, 99.0, 6.0)), Vector2(120.0, 70.0))

func test_scaled_xz_offsets_ignore_y() -> void:
	_anchor_a.global_position = Vector3(1.0, 2.0, 3.0)
	_anchor_b.global_position = Vector3(11.0, 2.0, 13.0)
	var projected_position: Vector2 = _minimap.world_to_map_position(Vector3(4.0, 200.0, -2.0))
	assert_eq(projected_position, Vector2(106.0, 40.0))

func test_out_of_bounds_offsets_are_not_clamped() -> void:
	_anchor_a.global_position = Vector3.ZERO
	_anchor_b.global_position = Vector3(10.0, 0.0, 0.0)
	_minimap.map_anchor_a_pixels = Vector2(100.0, 50.0)
	_minimap.map_anchor_b_pixels = Vector2(120.0, 50.0)
	var projected_position: Vector2 = _minimap.world_to_map_position(Vector3(-100.0, 0.0, 200.0))
	assert_eq(projected_position, Vector2(-100.0, 450.0))

func test_projection_availability_requires_anchor_pairs_and_texture() -> void:
	assert_true(_minimap.is_projection_available())
	_minimap.world_anchor_a = null
	assert_false(_minimap.is_projection_available())
	_minimap.world_anchor_a = _anchor_a
	_minimap.world_anchor_b = null
	assert_false(_minimap.is_projection_available())
	_minimap.world_anchor_b = _anchor_b
	_minimap.map_texture = null
	assert_false(_minimap.is_projection_available())
	_minimap.map_texture = _make_texture()
	_minimap.map_anchor_a_pixels = Vector2(INF, 0.0)
	assert_false(_minimap.is_projection_available())
	_minimap.map_anchor_a_pixels = Vector2(100.0, 50.0)
	_minimap.map_anchor_b_pixels = Vector2(NAN, 70.0)
	assert_false(_minimap.is_projection_available())

func test_projection_availability_rejects_unusable_anchor_geometry() -> void:
	_anchor_b.global_position = _anchor_a.global_position
	assert_false(_minimap.is_projection_available())
	_anchor_b.global_position = Vector3(20.0, 0.0, 6.0)
	_minimap.map_anchor_b_pixels = _minimap.map_anchor_a_pixels
	assert_false(_minimap.is_projection_available())

func test_projection_derives_rotation_from_anchor_pairs() -> void:
	_anchor_a.global_position = Vector3.ZERO
	_anchor_b.global_position = Vector3(10.0, 0.0, 10.0)
	_minimap.map_anchor_a_pixels = Vector2.ZERO
	_minimap.map_anchor_b_pixels = Vector2(20.0, 0.0)
	assert_true(_minimap.is_projection_available())
	assert_almost_eq(_minimap.get_derived_map_scale(), sqrt(2.0), 0.001)
	assert_eq(_minimap.world_to_map_position(Vector3(10.0, 0.0, 10.0)), Vector2(20.0, 0.0))
	assert_eq(_minimap.world_to_map_position(Vector3(-10.0, 0.0, 10.0)), Vector2(0.0, 20.0))

func test_invalid_projection_returns_safe_zero_without_anchor() -> void:
	_minimap.world_anchor_a = null
	assert_eq(_minimap.world_to_map_position(Vector3(3.0, 0.0, 5.0)), Vector2.ZERO)

func test_demo_vista_configured_minimap_is_projection_ready() -> void:
	var scene: PackedScene = load("res://zones/demo_vista/zoneobservatorio.tscn") as PackedScene
	var zone: Node = add_child_autoqfree(scene.instantiate())
	var zone_minimap: Node = zone.get_node("ZoneMinimap")
	assert_true(zone_minimap.call("is_projection_available"), zone_minimap.call("get_projection_unavailable_reason"))

func _make_texture() -> Texture2D:
	var image: Image = Image.create(4, 4, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	return ImageTexture.create_from_image(image)
