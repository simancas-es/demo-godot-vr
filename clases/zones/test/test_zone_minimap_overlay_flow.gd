extends GutTest

const MinimapMenuScene := preload("res://menus/minimap/minimap_menu.tscn")
const MinimapControlScene := preload("res://menus/minimap/minimap_control.tscn")
const WorldMinimapScene := preload("res://models/labels/minimap.tscn")
const MinimapController := preload("res://systems/system-minimap/minimap_controller.gd")
const MinimapTracker := preload("res://systems/system-minimap/minimap_tracker.gd")
const StateInSceneScript := preload("res://menus/fsm/menustates/stateinscene.gd")
const ZoneMinimap := preload("res://clases/zones/zone_minimap.gd")

class TestZone extends BaseZone:
	pass

var _menu: Control = null
var _manager: MenuManager = null
var _state: StateMenus = null
var _root: GameRoot = null
var _zone: TestZone = null
var _anchor_a: Node3D = null
var _anchor_b: Node3D = null
var _tracked_node: Node3D = null
var _tracker: MinimapTracker = null
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
	_minimap.name = "ZoneMinimap"
	_zone.add_child(_minimap)
	_minimap.world_anchor_a = _anchor_a
	_minimap.world_anchor_b = _anchor_b
	_minimap.map_texture = _make_texture()
	_minimap.map_anchor_a_pixels = Vector2.ZERO
	_minimap.map_anchor_b_pixels = Vector2(10.0, 10.0)
	_zone.zone_minimap = _minimap
	_tracked_node = Node3D.new()
	_zone.add_child(_tracked_node)
	_tracker = MinimapTracker.new()
	_tracker.tracker_id = &"fpv_player"
	_tracker.display_name = "Player"
	_tracker.centers_minimap = true
	_tracked_node.add_child(_tracker)
	_root.current_scene = _zone

func after_each() -> void:
	_tracked_node = null
	_tracker = null
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
	_tracked_node.position = Vector3.ZERO
	_state.toggle_minimap_overlay()
	var old_offset: Vector2 = _menu.get_last_map_offset()
	_tracked_node.position = Vector3(3.0, 0.0, -2.0)
	_state.refresh_minimap_overlay()
	assert_true(_manager.is_minimap_visible())
	assert_ne(_menu.get_last_map_offset(), old_offset)

func test_menu_renders_controller_output_without_fpv_node() -> void:
	var generic_root: Node3D = add_child_autoqfree(Node3D.new())
	var tracked_node: Node3D = Node3D.new()
	tracked_node.position = Vector3(2.0, 0.0, 1.0)
	generic_root.add_child(tracked_node)
	var tracker: MinimapTracker = MinimapTracker.new()
	tracker.tracker_id = &"generic_center"
	tracker.display_name = "Generic"
	tracker.centers_minimap = true
	tracked_node.add_child(tracker)
	var controller: MinimapController = MinimapController.new()
	controller.bind(_minimap, generic_root)
	assert_true(controller.refresh(), controller.get_unavailable_reason())
	_menu.show_for(controller)
	assert_true(_menu.is_open())
	assert_ne(_menu.get_last_map_offset(), Vector2.ZERO)

func test_minimap_control_renders_controller_output_without_menu_state() -> void:
	var controller: MinimapController = _make_generic_controller()
	var minimap_control: Control = MinimapControlScene.instantiate() as Control
	add_child_autoqfree(minimap_control)
	assert_true(minimap_control.show_for(controller))
	assert_ne(minimap_control.get_last_map_offset(), Vector2.ZERO)

func test_world_minimap_binds_controller_from_node_paths() -> void:
	var world_minimap: Node3D = WorldMinimapScene.instantiate() as Node3D
	world_minimap.set("projection_source_path", NodePath("../ZoneMinimap"))
	world_minimap.set("tracker_root_path", NodePath(".."))
	_zone.add_child(world_minimap)
	assert_true(world_minimap.refresh(), world_minimap.get_controller().get_unavailable_reason())
	assert_true(world_minimap.visible)
	assert_not_null(world_minimap.get_minimap_control())
	assert_not_null(world_minimap.get_minimap_control().get_node("%MapImage").texture)
	assert_true(world_minimap.get_minimap_control().get_node("%PlayerImage").visible)
	assert_ne(world_minimap.get_minimap_control().get_last_map_offset(), Vector2.ZERO)

func test_world_minimap_retries_binding_when_tracker_appears_after_ready() -> void:
	_tracked_node.remove_child(_tracker)
	_tracker.free()
	_tracker = null
	var world_minimap: Node3D = WorldMinimapScene.instantiate() as Node3D
	world_minimap.set("projection_source_path", NodePath("../ZoneMinimap"))
	world_minimap.set("tracker_root_path", NodePath(".."))
	_zone.add_child(world_minimap)
	assert_false(world_minimap.visible)
	assert_eq(world_minimap.get_unavailable_reason(), "no minimap trackers")
	var late_tracker: MinimapTracker = MinimapTracker.new()
	late_tracker.tracker_id = &"late_player"
	late_tracker.display_name = "Late Player"
	late_tracker.centers_minimap = true
	_tracked_node.add_child(late_tracker)
	simulate(world_minimap, 2, 0.6)
	assert_true(world_minimap.visible)
	assert_true(world_minimap.get_controller().is_available(), world_minimap.get_unavailable_reason())
	assert_not_null(world_minimap.get_minimap_control())
	assert_not_null(world_minimap.get_minimap_control().get_node("%MapImage").texture)
	assert_true(world_minimap.get_minimap_control().get_node("%PlayerImage").visible)
	assert_ne(world_minimap.get_minimap_control().get_last_map_offset(), Vector2.ZERO)

func _make_generic_controller() -> MinimapController:
	var generic_root: Node3D = add_child_autoqfree(Node3D.new())
	var tracked_node: Node3D = Node3D.new()
	tracked_node.position = Vector3(2.0, 0.0, 1.0)
	generic_root.add_child(tracked_node)
	var tracker: MinimapTracker = MinimapTracker.new()
	tracker.tracker_id = &"generic_center"
	tracker.display_name = "Generic"
	tracker.centers_minimap = true
	tracked_node.add_child(tracker)
	var controller: MinimapController = MinimapController.new()
	controller.bind(_minimap, generic_root)
	assert_true(controller.refresh(), controller.get_unavailable_reason())
	return controller

func _make_texture() -> Texture2D:
	var image: Image = Image.create(8, 8, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	return ImageTexture.create_from_image(image)
