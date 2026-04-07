extends StateBase
#class_name InventoryStateOnlyBar

const StateBase := INVENTORY_UIDCLASSREF.StateBase

const InventoryUI := INVENTORY_UIDCLASSREF.InventoryUI
const InventoryStateGrid := INVENTORY_UIDCLASSREF.InventoryStateGrid
const InventoryBottomBar := INVENTORY_UIDCLASSREF.InventoryBottomBar
const InventoryGrid := INVENTORY_UIDCLASSREF.InventoryGrid
const InspectPanel := INVENTORY_UIDCLASSREF.InspectPanel

@onready var state_grid : InventoryStateGrid = %grid
@onready var bbar : InventoryBottomBar = %BottomBar
@onready var fullinvpanel : PanelContainer = %FullInventoryPanel
@onready var inspectpanel : InspectPanel = %PanelContainerInspect

@export var inventoryui : InventoryUI

#signal requested_open_inv

func _ready() -> void:
	bbar.visible = false
	
func enter() -> void:
	bbar.visible = true
	fullinvpanel.visible = false
	inspectpanel.clear_inspect()
	entered.emit()

	pass
	
func exit() -> void:
	bbar.visible = false
	
	pass
	

func process_input(_event : InputEvent) -> StateBase:
	if Input.is_action_just_pressed(INVENTORYUISETTINGS.ACTION_OPEN):
		#TODO Other menus opened at the same time... Priority
		get_viewport().set_input_as_handled()
		#requested_open_inv.emit()
		inventoryui.inventory_action_open.emit()
		
	if Input.is_action_just_pressed(INVENTORYUISETTINGS.ACTION_SLOT_LEFT):
		bbar.select_offset(-1)
		get_viewport().set_input_as_handled()
	elif Input.is_action_just_pressed(INVENTORYUISETTINGS.ACTION_SLOT_RIGHT):
		bbar.select_offset(+1)
		get_viewport().set_input_as_handled()	
	elif Input.is_action_just_pressed(INVENTORYUISETTINGS.ACTION_DESELECT):
		if bbar.is_selecting():
			bbar.deselect()
			get_viewport().set_input_as_handled()	

	
	return null
