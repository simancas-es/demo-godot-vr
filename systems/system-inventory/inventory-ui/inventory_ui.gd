extends Control 
#class_name InventoryUI
const InventoryUI := INVENTORY_UIDCLASSREF.InventoryUI
const Inventory := INVENTORY_UIDCLASSREF.Inventory
const StateMachineBase := INVENTORY_UIDCLASSREF.StateMachineBase
const InventoryBottomBar := INVENTORY_UIDCLASSREF.InventoryBottomBar
const InventoryGrid := INVENTORY_UIDCLASSREF.InventoryGrid
const InspectPanel := INVENTORY_UIDCLASSREF.InspectPanel
const StateBase := INVENTORY_UIDCLASSREF.StateBase


##Collection of:
##Inventory bar at the bottom 
##Pick up item


var SIZE = 4
var inventory : Inventory

@onready var fsm : StateMachineBase = %StateMachine
@onready var bottombar : InventoryBottomBar = %BottomBar
@onready var gridinv : InventoryGrid = %InventoryGrid
@onready var inspectpanel : InspectPanel = %PanelContainerInspect

@onready var state_invisible : StateBase = %invisible
@onready var state_onlybar : StateBase = %only_bar
@onready var state_grid : StateBase = %grid

#signal requested_open_inv
signal opened_full_inv
signal closed_full_inv

#Integration signals
signal inventory_action_open

func with_inventory(inv : Inventory) -> InventoryUI:
	SIZE = inv.SIZE
	inventory = inv

	return self
	
func _ready() -> void:	
	assert(bottombar != null)
	assert(gridinv != null)
	assert(inspectpanel != null)
	#bottombar.inventory_action_open.connect(inventory_action_open.emit)
	
	
	bottombar.init_bar(inventory)
	gridinv.init_grid(2, inventory)
	inspectpanel.init_inspect(inventory)

	connect_logic_signals()	
	
	fsm.init()	
	
	
func connect_logic_signals() -> void:
	state_invisible.entered.connect(show_inventory_menus.bind(false))
	state_invisible.exited.connect(show_inventory_menus.bind(true))
	
	state_onlybar.entered.connect(on_entered_onlybar)
	state_grid.entered.connect(on_entered_grid)
	#state_onlybar.requested_open_inv.connect(requested_open_inv.emit)

func activate(enable : bool) -> void:
	if enable: fsm.change_state(state_onlybar)
	else: fsm.change_state(state_invisible)

func open_full() -> void:
	fsm.change_state(state_grid)

func on_entered_grid() -> void:
	opened_full_inv.emit()

func on_entered_onlybar() -> void:
	closed_full_inv.emit()	

	
func show_inventory_menus(enable : bool) -> void:
	self.visible = enable

func _process(delta: float) -> void:
	fsm.process_frame(delta)

func _physics_process(delta: float) -> void:
	fsm.process_physics(delta)
	
func _input(event: InputEvent) -> void:
	fsm.process_input(event)
