extends RefCounted
class_name InteractionHintResolver

const InteractionHintContextScript := preload("res://clases/fpv/interaction_hint_context.gd")

static func resolve(interactables: Array[Interaction], playerdata: PlayerData) -> Array[InteractionHint]:
	var context: InteractionHintContextScript = InteractionHintContextScript.from_playerdata(playerdata)
	return resolve_with_context(interactables, context)

static func resolve_with_context(interactables: Array[Interaction], context: InteractionHintContextScript) -> Array[InteractionHint]:
	var hints: Array[InteractionHint] = []

	for action_variant in ENUMS.ACTION_KW.keys():
		var action: ENUMS.ACTION = action_variant
		for item in interactables:
			if not is_instance_valid(item):
				continue
			if item.available_hint_for_context(context, action):
				var unformatted_hint: String = item.get_hint_for_context(context, action)
				var input_action: String = ENUMS.ACTION_KW[action]
				var key_text: String = ENUMS.get_keystring(action)
				hints.append(InteractionHint.new(
						action,
						input_action,
						key_text,
						_format_hint(unformatted_hint, key_text, context, item)))
				break

	return hints

static func resolve_strings(interactables: Array[Interaction], playerdata: PlayerData) -> Array[String]:
	var context: InteractionHintContextScript = InteractionHintContextScript.from_playerdata(playerdata)
	return resolve_strings_with_context(interactables, context)

static func resolve_strings_with_context(interactables: Array[Interaction], context: InteractionHintContextScript) -> Array[String]:
	var hint_strings: Array[String] = []
	hint_strings.resize(ENUMS.ACTION_KW.size())

	var hints: Array[InteractionHint] = resolve_with_context(interactables, context)
	for index in range(min(hints.size(), hint_strings.size())):
		hint_strings[index] = hints[index].text

	return hint_strings

static func _format_hint(unformatted_hint: String, key_text: String, context: InteractionHintContextScript, item: Interaction) -> String:
	var selected_name: String = "???"
	if context != null and not context.selected_item_name.is_empty():
		selected_name = context.selected_item_name

	return unformatted_hint.format({
		key = key_text,
		name = item.get_hint_name(),
		selected = selected_name
	})
