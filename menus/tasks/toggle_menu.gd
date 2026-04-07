@tool
extends Node
var signal_name : String # Name from the signals class
# We set the export manually here
func _get_property_list() -> Array:
	var props = []
	if Engine.is_editor_hint():
		var signals_list = SignalManager.new().get_signal_list().map(func(s): return s.name)
		props.append({
			"name": "signal_name",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": ",".join(signals_list),
			"usage": PROPERTY_USAGE_DEFAULT
		})
	return props
	
func _ready() -> void:	
	if Signals.has_signal(signal_name):	
		Signals.connect(signal_name, on_toggle_menu)
	else:
		push_error("Missing signal: %s" % signal_name)
func on_toggle_menu() -> void:
	get_parent().visible = !get_parent().visible
