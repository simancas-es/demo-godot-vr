extends StateBase
#class_name InventoryStateGrid
const StateBase := INVENTORY_UIDCLASSREF.StateBase

const InventoryStateOnlyBar := INVENTORY_UIDCLASSREF.InventoryStateOnlyBar
const InventoryStateInspect := INVENTORY_UIDCLASSREF.InventoryStateInspect
const InventoryGrid := INVENTORY_UIDCLASSREF.InventoryGrid
const InspectPanel := INVENTORY_UIDCLASSREF.InspectPanel

@onready var state_onlybar : InventoryStateOnlyBar = %only_bar
@onready var state_inspect : InventoryStateInspect = %inspect

@onready var grid : InventoryGrid = %InventoryGrid
@onready var inspect_panel : InspectPanel = %PanelContainerInspect
@onready var fullinvpanel : PanelContainer = %FullInventoryPanel

func _ready() -> void:
	#set_process_input(false)
	fullinvpanel.visible = false
	
func enter() -> void:
	fullinvpanel.visible = true
	entered.emit()
	pass
	
func exit() -> void:
	exited.emit()
	pass

func process_frame(delta : float) -> StateBase:
	inspect_panel.process_frame(delta)
	return null
	
func process_input(_event: InputEvent) -> StateBase:
	
	if Input.is_action_just_pressed(INVENTORYUISETTINGS.ACTION_OPEN):
		get_viewport().set_input_as_handled()
		return state_onlybar
	
	elif Input.is_action_just_pressed(INVENTORYUISETTINGS.ACTION_ESCAPE):
		get_viewport().set_input_as_handled()
		return state_onlybar
		
	elif Input.is_action_just_pressed(INVENTORYUISETTINGS.ACTION_SLOT_LEFT) or Input.is_action_just_pressed(INVENTORYUISETTINGS.ACTION_LEFT):
		grid.change_focus_to(InventoryGrid.DIR.LEFT)
		get_viewport().set_input_as_handled()
		
	elif Input.is_action_just_pressed(INVENTORYUISETTINGS.ACTION_SLOT_RIGHT) or Input.is_action_just_pressed(INVENTORYUISETTINGS.ACTION_RIGHT):
		grid.change_focus_to(InventoryGrid.DIR.RIGHT)
		get_viewport().set_input_as_handled()
		
	elif Input.is_action_just_pressed(INVENTORYUISETTINGS.ACTION_DOWN):
		grid.change_focus_to(InventoryGrid.DIR.DOWN)
		get_viewport().set_input_as_handled()
		
	elif Input.is_action_just_pressed(INVENTORYUISETTINGS.ACTION_UP):
		grid.change_focus_to(InventoryGrid.DIR.UP)
		get_viewport().set_input_as_handled()
	
	elif Input.is_action_just_pressed(INVENTORYUISETTINGS.ACTION_INTERACT):
		if grid.get_currently_focused_slot() == -1 : pass
		else:
			get_viewport().set_input_as_handled()
			return state_inspect
		
		
	return null
