extends Node

const Inventory := INVENTORY_UIDCLASSREF.Inventory
const InventoryObjectInformation := INVENTORY_UIDCLASSREF.InventoryObjectInformation
const InteractionHintContextScript := preload("res://clases/fpv/interaction_hint_context.gd")
const InteractionDoorScript := preload("res://clases/interaction/door_base.gd")

var _failures: Array[String] = []

func _ready() -> void:
	_test_context_defaults()
	_test_context_from_playerdata()
	_test_base_interaction_context_parity()
	_test_door_context_hints()
	_test_resolver_context_path()

	if _failures.is_empty():
		print("test_fpv_hint_context: passed")
		get_tree().quit(0)
	else:
		for failure: String in _failures:
			push_error(failure)
		get_tree().quit(1)

func _test_context_defaults() -> void:
	var context: InteractionHintContextScript = InteractionHintContextScript.from_playerdata(null)
	_check(context.selected_item_id == INVENTORYSETTINGS.ID.INVALID, "default selected item id should be INVALID")
	_check(context.selected_item_class == INVENTORYSETTINGS.CLASS.DEFAULT, "default selected item class should be DEFAULT")
	_check(context.selected_item_name == "", "default selected item name should be empty")
	_check(not context.locale.is_empty(), "default locale should not be empty")

func _test_context_from_playerdata() -> void:
	var playerdata: PlayerData = _make_playerdata_with_item(
			INVENTORYSETTINGS.ID.DUNGEON_KEYS,
			INVENTORYSETTINGS.CLASS.KEY,
			"Dungeon Key")
	var context: InteractionHintContextScript = InteractionHintContextScript.from_playerdata(playerdata)

	_check(context.selected_item_id == INVENTORYSETTINGS.ID.DUNGEON_KEYS, "context should copy selected item id")
	_check(context.selected_item_class == INVENTORYSETTINGS.CLASS.KEY, "context should copy selected item class")
	_check(context.selected_item_name == "Dungeon Key", "context should copy translated selected item name")

	playerdata.free()

func _test_base_interaction_context_parity() -> void:
	var interaction: Interaction = Interaction.new()
	interaction.actions = [ENUMS.ACTION.TAKE]
	interaction.name = "Context Item"

	var no_item_context: InteractionHintContextScript = InteractionHintContextScript.new()
	_check(interaction.available_hint_for_context(no_item_context, ENUMS.ACTION.TAKE), "base context should expose configured action")
	_check(interaction.available_hint_for_item(null, ENUMS.ACTION.TAKE), "base legacy wrapper should expose configured action with null playerdata")
	_check(
			interaction.get_hint_for_context(no_item_context, ENUMS.ACTION.TAKE) == interaction.get_hint_for_item(null, ENUMS.ACTION.TAKE),
			"base legacy and context hint text should match")

	var key_context: InteractionHintContextScript = _make_context(
			INVENTORYSETTINGS.ID.DUNGEON_KEYS,
			INVENTORYSETTINGS.CLASS.KEY,
			"Dungeon Key")
	var key_playerdata: PlayerData = _make_playerdata_with_item(
			INVENTORYSETTINGS.ID.DUNGEON_KEYS,
			INVENTORYSETTINGS.CLASS.KEY,
			"Dungeon Key")
	var player_context: InteractionHintContextScript = InteractionHintContextScript.from_playerdata(key_playerdata)

	interaction.special_hint_text[INVENTORYSETTINGS.ID.DUNGEON_KEYS] = "Use {selected} [{key}]"
	_check(interaction.available_hint_for_context(key_context, ENUMS.ACTION.INTERACT), "base context should expose special selected-item hint")
	_check(
			interaction.get_hint_for_context(player_context, ENUMS.ACTION.INTERACT) == interaction.get_hint_for_item(key_playerdata, ENUMS.ACTION.INTERACT),
			"base special hint should match between context and legacy path")

	interaction.free()
	key_playerdata.free()

func _test_door_context_hints() -> void:
	var door: InteractionDoorScript = InteractionDoorScript.new()
	var no_item_context: InteractionHintContextScript = InteractionHintContextScript.new()
	var key_context: InteractionHintContextScript = _make_context(
			INVENTORYSETTINGS.ID.DUNGEON_KEYS,
			INVENTORYSETTINGS.CLASS.KEY,
			"Dungeon Key")
	var non_key_context: InteractionHintContextScript = _make_context(
			INVENTORYSETTINGS.ID.BEAKER,
			INVENTORYSETTINGS.CLASS.DEFAULT,
			"Beaker")

	door._status = InteractionDoorScript.STATUS.CLOSED
	door._lock = InteractionDoorScript.LOCK.LOCKED
	_check(door.call("available_hint_for_context", no_item_context, ENUMS.ACTION.INTERACT), "locked door should expose interact hint availability")
	_check(String(door.call("get_hint_for_context", no_item_context, ENUMS.ACTION.INTERACT)) == "", "locked door with no item should keep empty text")
	_check(String(door.call("get_hint_for_context", non_key_context, ENUMS.ACTION.INTERACT)) == "", "locked door with non-key should keep empty text")
	_check(String(door.call("get_hint_for_context", key_context, ENUMS.ACTION.INTERACT)) == tr("Unlock [{key}]"), "locked door with key should show unlock text")

	door._lock = InteractionDoorScript.LOCK.UNLOCKED
	_check(String(door.call("get_hint_for_context", no_item_context, ENUMS.ACTION.INTERACT)) == tr("Open [{key}]"), "unlocked closed door with no item should show open text")
	_check(String(door.call("get_hint_for_context", key_context, ENUMS.ACTION.INTERACT)) == tr("Lock [{key}]"), "unlocked closed door with key should show lock text")
	_check(String(door.call("get_hint_for_context", non_key_context, ENUMS.ACTION.INTERACT)) == "", "unlocked closed door with non-key should keep empty text")

	door._status = InteractionDoorScript.STATUS.OPENED
	_check(String(door.call("get_hint_for_context", no_item_context, ENUMS.ACTION.INTERACT)) == tr("Close [{key}]"), "opened door with no item should show close text")
	_check(String(door.call("get_hint_for_context", key_context, ENUMS.ACTION.INTERACT)) == "", "opened door with key should keep empty text")
	_check(String(door.call("get_hint_for_context", non_key_context, ENUMS.ACTION.INTERACT)) == "", "opened door with non-key should keep empty text")

	door.free()

func _test_resolver_context_path() -> void:
	var interaction: Interaction = Interaction.new()
	interaction.name = "Resolver Item"
	interaction.actions = [ENUMS.ACTION.INTERACT]
	interaction.hint_text[ENUMS.ACTION.INTERACT] = "Use {selected} on {name} [{key}]"

	var context: InteractionHintContextScript = _make_context(
			INVENTORYSETTINGS.ID.DUNGEON_KEYS,
			INVENTORYSETTINGS.CLASS.KEY,
			"Dungeon Key")
	var hints: Array[InteractionHint] = InteractionHintResolver.resolve_with_context([interaction], context)
	var key_text: String = ENUMS.get_keystring(ENUMS.ACTION.INTERACT)
	_check(hints.size() == 1, "resolver should return one context hint")
	if hints.size() == 1:
		_check(hints[0].text == "Use Dungeon Key on Resolver Item [%s]" % key_text, "resolver should format selected item, name, and key")

	var door: InteractionDoorScript = InteractionDoorScript.new()
	door._status = InteractionDoorScript.STATUS.CLOSED
	door._lock = InteractionDoorScript.LOCK.LOCKED
	var door_hints: Array[InteractionHint] = InteractionHintResolver.resolve_with_context([door], context)
	_check(door_hints.size() == 1, "resolver should support converted door provider")
	if door_hints.size() == 1:
		_check(door_hints[0].text == tr("Unlock [{key}]").format({key = key_text}), "resolver should format converted door provider")

	interaction.free()
	door.free()

func _make_context(item_id: INVENTORYSETTINGS.ID, item_class: INVENTORYSETTINGS.CLASS, item_name: String) -> InteractionHintContextScript:
	var context: InteractionHintContextScript = InteractionHintContextScript.new()
	context.selected_item_id = item_id
	context.selected_item_class = item_class
	context.selected_item_name = item_name
	return context

func _make_playerdata_with_item(item_id: INVENTORYSETTINGS.ID, item_class: INVENTORYSETTINGS.CLASS, item_name: String) -> PlayerData:
	var item_info: InventoryObjectInformation = InventoryObjectInformation.new()
	item_info.ID = item_id
	item_info.CLASS = item_class
	var locale: String = TranslationServer.get_locale()
	if locale.is_empty():
		locale = "en"
	var translations: Dictionary = {
		"en": {
			"name": item_name,
			"description": ""
		}
	}
	translations[locale] = {
		"name": item_name,
		"description": ""
	}
	item_info.inspect_translations = translations

	var info: Dictionary[int, InventoryObjectInformation] = {}
	info[item_id] = item_info
	var inventory: Inventory = Inventory.new(2, info)
	inventory.add_at_index(0, item_id, 1)
	inventory.currently_selected_idx = 0
	return PlayerData.new(null, inventory)

func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
