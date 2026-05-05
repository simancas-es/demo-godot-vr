extends RefCounted
class_name InteractionHintResolver

static func resolve(interactables: Array[Interaction], playerdata: PlayerData) -> Array[InteractionHint]:
	var hints: Array[InteractionHint] = []
	if playerdata == null:
		return hints

	for action_variant in ENUMS.ACTION_KW.keys():
		var action: ENUMS.ACTION = action_variant
		for item in interactables:
			if not is_instance_valid(item):
				continue
			if item.available_hint_for_item(playerdata, action):
				var unformatted_hint: String = item.get_hint_for_item(playerdata, action)
				var input_action: String = ENUMS.ACTION_KW[action]
				var key_text: String = ENUMS.get_keystring(action)
				hints.append(InteractionHint.new(
						action,
						input_action,
						key_text,
						_format_hint(unformatted_hint, key_text, playerdata, item)))
				break

	return hints

static func resolve_strings(interactables: Array[Interaction], playerdata: PlayerData) -> Array[String]:
	var hint_strings: Array[String] = []
	hint_strings.resize(ENUMS.ACTION_KW.size())

	var hints: Array[InteractionHint] = resolve(interactables, playerdata)
	for index in range(min(hints.size(), hint_strings.size())):
		hint_strings[index] = hints[index].text

	return hint_strings

static func _format_hint(unformatted_hint: String, key_text: String, playerdata: PlayerData, item: Interaction) -> String:
	var selected_name: String = "???"
	var selected_obj: INVENTORY_UIDCLASSREF.InventoryObjectInformation = playerdata.get_inventory().get_selected_obj_info()
	if selected_obj != null:
		selected_name = selected_obj.get_translated_name(TranslationServer.get_locale())

	return unformatted_hint.format({
		key = key_text,
		name = item.get_hint_name(),
		selected = selected_name
	})
