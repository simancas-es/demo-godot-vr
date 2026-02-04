extends PanelContainer
#class_name InventoryGrid

const InspectPanel := INVENTORY_UIDCLASSREF.InspectPanel
const Inventory_UI_Slot := INVENTORY_UIDCLASSREF.Inventory_UI_Slot
const Inventory := INVENTORY_UIDCLASSREF.Inventory

enum DIR { UP, RIGHT, DOWN, LEFT}

var SIZE : int = 4
var inventory : Inventory = null

var num_cols : int
var num_rows : int

@onready var grid : GridContainer = %GridItems
@onready var iteminspectorpanel : InspectPanel = %PanelContainerInspect

var slots : Array[Inventory_UI_Slot] = []
@export var slot_scene : PackedScene

##TODO: Currently selected but out of focus.
var current_selected_slot : int 

signal focused(idx : int) ##Show focused item in the item inspector


func init_grid(columns : int, inventory_ : Inventory) -> void:
	grid.columns = columns
	SIZE = inventory_.SIZE
	
	num_cols = columns
	num_rows = int(ceil(float(SIZE) / columns))
	
	inventory = inventory_
	for c in grid.get_children():
		grid.remove_child(c)
		c.queue_free()
		
	slots.clear()
	slots.resize(SIZE)
	for i in range(SIZE):
		var _slot : Inventory_UI_Slot = slot_scene.instantiate()
		#_slot.focused.connect(focused.emit.bind(i))
		_slot.focused.connect(on_focus_change.bind(i))
		grid.add_child(_slot)
		slots[i] = _slot
	update_slots([])
	
	if not inventory.updated.is_connected(update_slots):
		inventory.updated.connect(update_slots)
	
func update_slots(idxs : Array[bool]) -> void:
	for i in range(SIZE):
		if idxs.is_empty() or idxs[i]:
			var object = inventory.check_at_index(i)
			if object != null:
				var info = inventory.get_obj_info_from(i)
				slots[i].set_texture(info.texture)
				slots[i].set_qty(info.get_qty_str(object.qty))
			else:
				slots[i].set_null()
			#TODO Maybe a little animation
	pass

##Gets index of currently selected slot
func get_currently_focused_slot() -> int:
	var idx = -1
	for i in range(SIZE):
		if slots[i].is_focused():
			return i
	return idx
	
#Handles going in a particular direction from a grid slot index.	
func get_index_after_moving(from_idx : int, dir : DIR) -> int:	
	var cols = num_cols
	var rows = num_rows
	var lp = from_idx % cols
	var rp = int(from_idx/cols)
	
	if dir == DIR.UP:
		if rp == 0: pass #Ignore wrapping up
		else: rp = rp - 1
	elif dir == DIR.DOWN:
		if rp == rows -1: pass #Ignore wrapping down
		else: rp = rp + 1
		if ((rp+1) * (lp+1)) > SIZE: rp = rp-1
	elif dir == DIR.LEFT:
		if lp == 0 : pass #Ignore going left
		else: lp = lp -1
	elif dir == DIR.RIGHT:
		if lp == cols -1 : pass #Ignore going right
		else: lp = lp +1
		if ((rp+1) * (lp+1)) > SIZE: lp = lp-1
	
	rp = posmod(rp, rows)
	lp = posmod(lp, cols)
	var obj_num = (rp * cols + lp) #New index
	return obj_num

func change_focus_to(dir : DIR) -> void:
	var current_idx = get_currently_focused_slot()
	var new_idx : int
	if current_idx == -1 :
		new_idx = 0
	else:	
		new_idx = get_index_after_moving(current_idx, dir)
	if current_idx != new_idx:
		slots[new_idx].focus(true)
		
func on_focus_change(idx : int) -> void:
	focused.emit(idx)
	
