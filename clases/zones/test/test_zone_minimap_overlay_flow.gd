extends GutTest

const MinimapMenuScene := preload("res://menus/minimap/minimap_menu.tscn")
const StateInSceneScript := preload("res://menus/fsm/menustates/stateinscene.gd")
const ZoneMinimap := preload("res://clases/zones/zone_minimap.gd")

class TestZone extends BaseZone:
	var test_fpv: FPV = null

	func get_active_fpv() -> FPV:
		return test_fpv

var _menu: Control = null
var _manager: MenuManager = null
var _state: StateMenus = null
var _root: GameRoot = null
var _zone: TestZone = null
var _anchor_a: Node3D = null
var _anchor_b: Node3D = null
var _fpv: FPV = null
var _minimap: ZoneMinimap = null

func before_each() -> void:
	_menu = MinimapMenuScene.instantiate() as Control
	add_child_autoqfree(_menu)
	_manager = autoqfree(MenuManager.new())
	_manager.minimap_menu = _menu
	_root = autoqfree(GameRoot.new())
	_state = autoqfree(StateInSceneScript.new())
	_state.parent = _root
	_state.menu_manager = _manager
	_state.debug_task_show = autoqfree(VBoxContainer.new())
	_zone = add_child_autoqfree(TestZone.new())
	_anchor_a = Node3D.new()
	_zone.add_child(_anchor_a)
	_anchor_b = Node3D.new()
	_anchor_b.position = Vector3(1.0, 0.0, 1.0)
	_zone.add_child(_anchor_b)
	_minimap = ZoneMinimap.new()
	_zone.add_child(_minimap)
	_minimap.world_anchor_a = _anchor_a
	_minimap.world_anchor_b = _anchor_b
	_minimap.map_texture = _make_texture()
	_minimap.map_anchor_a_pixels = Vector2.ZERO
	_minimap.map_anchor_b_pixels = Vector2(10.0, 10.0)
	_zone.zone_minimap = _minimap
	_fpv = autoqfree(FPV.new())
	_zone.test_fpv = _fpv
	_root.current_scene = _zone

func after_each() -> void:
	_fpv = null
	_minimap = null
	_anchor_a = null
	_anchor_b = null
	_zone = null
	_menu = null
	_root = null
	_manager = null
	_state = null

func test_toggle_minimap_overlay_on_and_off() -> void:
	_state.toggle_minimap_overlay()
	assert_true(_manager.is_minimap_visible())
	_state.toggle_minimap_overlay()
	assert_false(_manager.is_minimap_visible())

func test_no_map_emits_signal_and_opens_no_overlay() -> void:
	_zone.zone_minimap = null
	var signal_emitted: Array[bool] = [false]
	var callback: Callable = func() -> void:
		signal_emitted[0] = true
	Signals.no_minimap_available.connect(callback, CONNECT_ONE_SHOT)
	_state.toggle_minimap_overlay()
	assert_true(signal_emitted[0])
	assert_false(_manager.is_minimap_visible())

func test_leaving_state_closes_overlay() -> void:
	_state.toggle_minimap_overlay()
	assert_true(_manager.is_minimap_visible())
	_state.close_minimap_overlay()
	assert_false(_manager.is_minimap_visible())

func test_reset_refresh_keeps_overlay_visible_and_updates_offset() -> void:
	_fpv.position = Vector3.ZERO
	_state.toggle_minimap_overlay()
	var old_offset: Vector2 = _menu.get_last_map_offset()
	_fpv.position = Vector3(3.0, 0.0, -2.0)
	_state.refresh_minimap_overlay()
	assert_true(_manager.is_minimap_visible())
	assert_ne(_menu.get_last_map_offset(), old_offset)

func _make_texture() -> Texture2D:
	var image: Image = Image.create(8, 8, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	return ImageTexture.create_from_image(image)
