extends StateMenus
const InventoryUI := INVENTORY_UIDCLASSREF.InventoryUI

@onready var state_inscene : StateMenus = %InScene
@onready var menu_inventory : InventoryUI
@export var inventoryui_scene : PackedScene ##Instantiate through code
var inventoryui : InventoryUI

@onready var pc : PanelContainer = %PanelContainer #HACK


func _ready() -> void:
	state_inscene.entered.connect(on_entered_inscene.bind(true))
	state_inscene.exited.connect(on_entered_inscene.bind(false))
	
	#Inv
	inventoryui = inventoryui_scene.instantiate()
	inventoryui.with_inventory(GameState.get_player().get_inventory()) #HACK player_idx
	inventoryui.inventory_action_open.connect(Signals.inventory_action_open.emit) 
	
	pc.add_child(inventoryui) #HACK Make the player responsible for it

func connect_signals() -> void:
	inventoryui.opened_full_inv.connect(opened_full_inventory)
	inventoryui.closed_full_inv.connect(closed_full_inventory)
	
func disconnect_signals() -> void:
	inventoryui.opened_full_inv.disconnect(opened_full_inventory)
	inventoryui.closed_full_inv.disconnect(closed_full_inventory)

func exit() -> void:
	super()
	ControllerManager.enable_ctrls(true)
	disconnect_signals()
	
func enter() -> void:
	super()
	ControllerManager.enable_ctrls(false)
	connect_signals()
	parent.pause_game(false)
	on_inventory()
	

func on_entered_inscene(is_in : bool) -> void:
	inventoryui.activate(is_in)
	#request_current_fpvmode.emit()
	
##Opens the full inventory menu if its possible
func on_inventory() -> void:
	inventoryui.open_full()
	pass

func opened_full_inventory() -> void:
	Signals.release_mouse.emit()
	Signals.set_fixed_camera.emit(true)
	pass
	
func closed_full_inventory() -> void:
		#GameController_locks -= 1
		#request_current_fpvmode.emit()
		go_back.emit()
		pass
	
