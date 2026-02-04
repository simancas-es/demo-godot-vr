extends Node
#class_name Inventory
##Class that holds item in both an 
##Inventory and chest have different limitations.
##Items can be stackable and non stackable, and have logic when used

signal changed_currently_selected

#Importing classes
const InventoryObject := INVENTORY_UIDCLASSREF.InventoryObject
const InventoryObjectInformation := INVENTORY_UIDCLASSREF.InventoryObjectInformation

##Both spaces
var array : Array[InventoryObject] = []
var array_test : Array[InventoryObject] = []
var SIZE : int = 6
var info : Dictionary[int, InventoryObjectInformation] = {} #INVENTORYSETTINGS.ID

var currently_selected_idx : int = -1: ##currently selected item
	set(value):
		currently_selected_idx = value
		changed_currently_selected.emit()
	
##Errors
enum ERROR {
	SUCCESS,
	NOT_ENOUGH_SPACE, #Adding more than allowed
	UNAVAILABLE_QTY, #cant remove that much
	EXCEEDING_MAX_STACK, #adding more than fits in the stack
	ID_MISMATCH,
	IDX_OUT_OF_BOUNDS, #index out of bounds
	NULLSLOT
}


signal updated(idxs : Array[int]) ##indexes of inventory. empty when all

func _init(size : int, inventory_object_information : Dictionary[int, InventoryObjectInformation]) -> void:
	SIZE = size
	info = inventory_object_information
	array.resize(SIZE)
	array_test.resize(SIZE)
	


##Check if an object can be inserted into the inventory by
##either stacking it with a similar object or by itself
##Just append everything and check size at the end if valid.
func add_item(object_id : INVENTORYSETTINGS.ID, qty : int) -> ERROR:
	#Create test array
	array_test.clear()
	array_test.resize(SIZE)
	for i in range(SIZE):
		if array[i] != null:
			array_test[i] = array[i].get_duplicate()
	
	var max_stack = info[object_id].STACK_MAX
	var idx_modified : Array[bool] = []; idx_modified.resize(SIZE)
	#First pass: fill already used slots
	for i in range(SIZE):
		if qty == 0: break;
		var i_obj : InventoryObject = array_test[i]
		if i_obj == null : continue
		if i_obj.id == object_id:
			var i_qty = array_test[i].qty
			var add_to_existing_slot = min(qty - i_qty, max_stack - i_qty)
			array_test[i].qty += add_to_existing_slot
			qty -= add_to_existing_slot
			if add_to_existing_slot > 0 : idx_modified[i] = true
			continue
	
#Second pass: fill empty slots with max_stack or qty
	for i in range(SIZE):
		if qty == 0: break;
		var i_obj = array_test[i]
		if i_obj == null:
			var add_to_existing_slot = min(max_stack, qty)
			array_test[i] = InventoryObject.new(object_id, add_to_existing_slot)
			qty -= add_to_existing_slot
			if add_to_existing_slot > 0 : idx_modified[i] = true

			continue

	#check constraints
	if qty > 0 : return ERROR.NOT_ENOUGH_SPACE
	
	#Else it worked
	array.clear()
	array.resize(SIZE)
	for i in range(SIZE):		
		array[i] = array_test[i]
	
	updated.emit(idx_modified)
	return ERROR.SUCCESS
	
	
##Checks whether it is possible to combine two slots
##This only happens if they are the same item
##or whether there is an entry in the combine table for them
func is_combinable(i : int, j : int) -> bool:
	if array[i].id == array[j].id : return true
	push_error("Not implemented!")
	#TODO Combine table with id1, qty1, id2, qty2 -> id3, qty3
	
	return false
	
##Get total amount of object of a certain id.
func get_total_amount(id : INVENTORYSETTINGS.ID) -> int:
	var q = 0
	for obj in array:
		if obj == null : continue
		if obj.id == id : q += obj.qty
	return q
	
func remove_item(id : INVENTORYSETTINGS.ID, qty : int) -> ERROR:
	var amount = get_total_amount(id)
	var idx_modified : Array[bool] = []; idx_modified.resize(SIZE)
	if amount < qty : return ERROR.UNAVAILABLE_QTY
	else:
		for i in range(SIZE):
			if array[i] == null : continue
			if array[i].id == id:
				var i_qty = array[i].qty
				var remove_from_slot = (min(qty, i_qty))
				array[i].qty -= remove_from_slot
				if (array[i].qty == 0) and (info[id].DISAPPEARS_AT_0): array[i] = null
				qty -= remove_from_slot
				if remove_from_slot >0 : idx_modified[i] = true
	updated.emit(idx_modified)
	return ERROR.SUCCESS
	
func remove_at_index(idx : int, qty : int) -> ERROR:
	var idx_modified : Array[bool] = []; idx_modified.resize(SIZE)
	if idx >= SIZE : return ERROR.IDX_OUT_OF_BOUNDS
	var err : ERROR
	if array[idx] == null:
		err = ERROR.UNAVAILABLE_QTY
	elif array[idx].qty >= qty:
		array[idx].qty -= qty
		idx_modified[idx] = true
		var id = array[idx].id
		if (array[idx].qty == 0) and (info[id].DISAPPEARS_AT_0): array[idx] = null
		
		err = ERROR.SUCCESS
	else:
		err = ERROR.UNAVAILABLE_QTY
	
	if err == ERROR.SUCCESS:
		updated.emit(idx_modified)
	return err
	
func delete_at_index(idx : int, _qty : int) -> ERROR:
	if array[idx] == null: return ERROR.NULLSLOT
	array[idx].queue_free()
	array[idx] = null
	updated.emit(idx)
	return ERROR.SUCCESS
	
#
###TODO: Check whether there is a fit for many objects of maybe different ids.
#func is_space_for_many(collection : Array[InventoryObject]) -> bool:
	#return false

##adds or removes at an index. Checks for errors
func add_at_index(idx : int, id : INVENTORYSETTINGS.ID, qty : int) -> ERROR:
	var idxs : Array[bool] = []; idxs.resize(SIZE);
	if idx >= SIZE : return ERROR.IDX_OUT_OF_BOUNDS
	var err : ERROR
	if array[idx] == null:
		if qty <1:
			err = ERROR.UNAVAILABLE_QTY
		elif qty > info[id].STACK_MAX:
			err = ERROR.EXCEEDING_MAX_STACK
		elif qty <= info[id].STACK_MAX:
			array[idx] = InventoryObject.new(id, qty)

			err = ERROR.SUCCESS
	elif array[idx].id == id:
		if array[idx].qty + qty < 0:
			err = ERROR.UNAVAILABLE_QTY
		elif (array[idx].qty + qty) > info[id].STACK_MAX:
			err = ERROR.EXCEEDING_MAX_STACK
		else:
			array[idx].qty += qty
			if array[idx].qty == 0: array[idx] = null #TODO autoupdate or something
			idxs[idx] = true;
			updated.emit(idxs)
			err = ERROR.SUCCESS
	elif array[idx].id != id:
		err = ERROR.ID_MISMATCH
		
	if err == ERROR.SUCCESS:
		idxs[idx] = true; updated.emit(idxs);
	return err

##Returns object at index
func check_at_index(idx : int) -> InventoryObject:
	if idx >= SIZE : return null
	return array[idx]

##Returns the InventoryObject selected.
func check_at_selected() -> InventoryObject:
	if currently_selected_idx >=0:
		return array[currently_selected_idx]
	else:
		return null
		
func remove_at_selected(qty : int) -> ERROR:
	if currently_selected_idx <0: return ERROR.IDX_OUT_OF_BOUNDS #TODO different error
	var error = remove_at_index(currently_selected_idx, qty)
	return error
	
func get_obj_info_from(idx : int) -> InventoryObjectInformation:
	var obj = array[idx]
	if obj == null : return null
	return info[obj.id]
	
##Get the id of the currently selected item
func get_selected_id() -> INVENTORYSETTINGS.ID:
	if currently_selected_idx >=0:
		if array[currently_selected_idx] == null: return -1
		return array[currently_selected_idx].id
	return -1
	
func get_selected_obj_info() -> InventoryObjectInformation:
	var idx = currently_selected_idx
	if idx >= 0:
		return get_obj_info_from(idx)
	return null
