extends RefCounted
class_name InteractionHint

var action: ENUMS.ACTION
var input_action: String = ""
var key_text: String = ""
var text: String = ""
var source: Interaction = null

func _init(
		action_: ENUMS.ACTION = ENUMS.ACTION.INTERACT,
		input_action_: String = "",
		key_text_: String = "",
		text_: String = "",
		source_: Interaction = null) -> void:
	action = action_
	input_action = input_action_
	key_text = key_text_
	text = text_
	source = source_
