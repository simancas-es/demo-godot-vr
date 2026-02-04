extends StateBase
#class_name InventoryStateInspect
const StateBase := INVENTORY_UIDCLASSREF.StateBase

const InventoryStateOnlyBar := INVENTORY_UIDCLASSREF.InventoryStateOnlyBar
const ItemInspect := INVENTORY_UIDCLASSREF.ItemInspect

@onready var state_onlybar : InventoryStateOnlyBar = %only_bar

##This state represents the inspector being able to manipulate the objects.
@onready var iteminspect : ItemInspect = %ItemInspect

func enter() -> void:
	iteminspect.auto = false

func exit() -> void:
	iteminspect.auto = true

func process_physics(delta : float) -> StateBase:
	iteminspect.process_physics(delta)
	return null

func process_input(_event : InputEvent) -> StateBase:
	if Input.is_action_just_pressed(INVENTORYUISETTINGS.ACTION_ESCAPE):
		go_back.emit()
	elif Input.is_action_just_pressed(INVENTORYUISETTINGS.ACTION_OPEN):
		return state_onlybar
		
	return null
		
	
