extends StateMenus


@onready var menu : MenuSettings = %MenuSettings

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	menu.go_back.connect(back)
	pass # Replace with function body.

func enter() -> void:
	super()
	menu.visible = true
func exit() -> void:
	super()
	menu.visible = false
	
func process_input(event : InputEvent) -> StateMenus:
	if event.is_action_released("menu"): #Check
		back()
		get_viewport().set_input_as_handled()
	return null
	
