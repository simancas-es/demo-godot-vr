extends CenterContainer
class_name MenuMainTitle
signal menuload
signal menusettings
signal menucredits
signal menuexit
	
@export var starting_button : ChoiceButton
var _selected : ChoiceButton

func _ready():
	starting_button.grab_focus()
	
func select(option : ChoiceButton):
	_selected = option
	
func press_selected():
	_selected.pressed.emit()
	
	
func button_load() -> void:
	menuload.emit()
	pass

func button_settings() -> void:
	menusettings.emit()
	pass
	
func button_credits() -> void:
	menucredits.emit()
	pass

func button_exit() -> void:
	menuexit.emit()
	pass
