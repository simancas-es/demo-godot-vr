extends PanelContainer
#class_name InventoryBottomBar

const Inventory_UI_Slot := INVENTORY_UIDCLASSREF.Inventory_UI_Slot
const Inventory := INVENTORY_UIDCLASSREF.Inventory

var SIZE : int = 4
var inventory : Inventory = null

@export var slot_scene : PackedScene
var slots : Array[Inventory_UI_Slot] = []

@onready var namehint_selected : Label = %NameHintSelected ##Hint of whats selected

#signal inventory_action_open


##Creates the bar at the bottom with the needed slots.
func init_bar(inventory_ : Inventory) -> void:
	SIZE = inventory_.SIZE
	inventory = inventory_
	var bar : HBoxContainer = %HBoxSlotbar
	for c in bar.get_children():
		bar.remove_child(c)
		c.queue_free()
		
	slots.clear()
	slots.resize(SIZE)
	for i in range(SIZE):
		var _slot = slot_scene.instantiate()	
		bar.add_child(_slot)
		slots[i] = _slot
	update_slots([])
	deselect()
	
	if not inventory.updated.is_connected(update_slots):
		inventory.updated.connect(update_slots)
	
	if not inventory.changed_currently_selected.is_connected(on_inventory_updated_selected):
		inventory.changed_currently_selected.connect(on_inventory_updated_selected)
		
	
##Deselects current inventory item
func deselect() -> void:	
	inventory.currently_selected_idx = -1
	
func on_inventory_updated_selected() -> void:
	select_index(inventory.currently_selected_idx)
	
#Focuses a particular index
func select_index(idx : int) -> void:
	if idx < 0:
		for i in slots.size():
			if slots[i].is_focused():
				slots[i].focus(false)
		namehint_selected.visible = false
		namehint_selected.text = "" #NO_TRANSLATE"
	else:
		slots[idx].focus(true)
				
		var _info = inventory.get_selected_obj_info()
		if _info != null:
			namehint_selected.visible = true
			namehint_selected.text = _info.get_translated_name(TranslationServer.get_locale())
		else:
			namehint_selected.visible = false
			namehint_selected.text = "" #NO_TRANSLATE
	
##Offset minus to the left. Positive to the right.
func select_offset(offset : int) -> void:
	for i in slots.size():
		if slots[i].is_focused():
			var new_idx = (i + offset + SIZE) % SIZE 
			inventory.currently_selected_idx = new_idx
			return
	inventory.currently_selected_idx = 0
	#slots[0].focus(true)
			
		
##Updates items in slots by number and image	
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
	select_index(inventory.currently_selected_idx)
			#TODO Maybe a little animation
	
