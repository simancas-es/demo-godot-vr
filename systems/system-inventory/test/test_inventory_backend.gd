extends Node

const InventoryObjectInformation := INVENTORY_UIDCLASSREF.InventoryObjectInformation
const Inventory := INVENTORY_UIDCLASSREF.Inventory

func _ready() -> void:
	assert (first_test()	)
	assert (second_test()  )
	assert(test_remove_item_across_multiple_slots())
	assert(test_remove_item_unavailable_qty())
	assert(test_add_at_index_stack_limit())
	assert(test_add_at_index_id_mismatch())
	assert(test_remove_at_index_errors())
	assert(test_delete_at_index())
	assert(test_currently_selected_operations())
	
	
func generate_info_1() -> Dictionary[int, InventoryObjectInformation]:
	var inf : Dictionary[int, InventoryObjectInformation] = {}
	var type1 = InventoryObjectInformation.new()
	type1.ID = 2
	type1.STACK_MAX = 3
	type1.qty_string = InventoryObjectInformation.MODE_QTY.NUMBER
	
	var type2 = InventoryObjectInformation.new()
	type2.ID = 3
	type2.STACK_MAX = 10
	type2.qty_string = InventoryObjectInformation.MODE_QTY.NOTHING
	
	inf[2] = type1
	inf[3] = type2
	
	return inf
	

func first_test() -> bool:
	var inv_info = generate_info_1()
	
	const slots = 4
	
	var iv = Inventory.new(slots, inv_info)
	var err : Inventory.ERROR
	
	err = iv.add_item(2, 3)
	assert(err == Inventory.ERROR.SUCCESS)
	assert(iv.get_total_amount(2) == 3)
	
	err = iv.add_item(2, 9)
	assert(err == Inventory.ERROR.SUCCESS)
	assert(iv.get_total_amount(2) == 12) # Stack max is 3, xo 3x4
	
	err = iv.add_item(2, 1)
	assert(err == Inventory.ERROR.NOT_ENOUGH_SPACE)
	assert(iv.get_total_amount(2) == 12) # Stays as is
	
	err = iv.remove_item(2, 1)
	assert (err == Inventory.ERROR.SUCCESS)
	assert(iv.get_total_amount(2) == 11) #we still have 4 stacks
	
	err = iv.add_item(3,2)
	assert (err == Inventory.ERROR.NOT_ENOUGH_SPACE)
	return true
	
func second_test() -> bool:
	var inv_info : Dictionary[int, InventoryObjectInformation] = {}
	
	var type1 = InventoryObjectInformation.new()
	type1.ID = 2
	type1.STACK_MAX = 1
	
	var type2 = InventoryObjectInformation.new()
	type2.ID = 3
	type2.STACK_MAX = 1
	
	
	inv_info[2] = type1
	inv_info[3] = type2
	
	var iv = Inventory.new(2, inv_info)
	var err : Inventory.ERROR
	
	iv.add_item(2, 1)
	iv.add_item(3, 1)
	err = iv.add_at_index(0, 2, -1)
	assert (err == Inventory.ERROR.SUCCESS)
	assert (iv.check_at_index(0) == null)
	
	
	return true
	
	
	
func test_remove_item_across_multiple_slots() -> bool:
	var info = generate_info_1()  # STACK_MAX for ID 2 is 3 (source: code above)
	var iv = Inventory.new(4, info)
	
	iv.add_item(2, 7)  
	# 7 items = 2 full stacks (3+3) and 1 remaining (1) = total 7
	
	assert(iv.get_total_amount(2) == 7)
	var err = iv.remove_item(2, 5)
	assert(err == Inventory.ERROR.SUCCESS)
	assert(iv.get_total_amount(2) == 2)
	return true

func test_remove_item_unavailable_qty() -> bool:
	var info = generate_info_1()
	var iv = Inventory.new(2, info)
	
	iv.add_item(2, 2)
	var err = iv.remove_item(2, 5)
	assert(err == Inventory.ERROR.UNAVAILABLE_QTY)
	assert(iv.get_total_amount(2) == 2)
	return true


func test_add_at_index_stack_limit() -> bool:
	var info = generate_info_1()  # STACK_MAX of ID 2 is 3
	var iv = Inventory.new(1, info)
	
	var err = iv.add_at_index(0, 2, 5)
	assert(err == Inventory.ERROR.EXCEEDING_MAX_STACK)
	assert(iv.check_at_index(0) == null)
	return true


func test_add_at_index_id_mismatch() -> bool:
	var info = generate_info_1()
	var iv = Inventory.new(2, info)
	
	iv.add_at_index(0, 2, 2)  # OK since STACK_MAX=3
	var err = iv.add_at_index(0, 3, 1)  # Different ID → ID_MISMATCH
	assert(err == Inventory.ERROR.ID_MISMATCH)
	return true


func test_remove_at_index_errors() -> bool:
	var info = generate_info_1()
	var iv = Inventory.new(2, info)
	
	var err = iv.remove_at_index(1, 1)
	assert(err == Inventory.ERROR.UNAVAILABLE_QTY)
	
	iv.add_item(2, 3)
	err = iv.remove_at_index(5, 1)  # index >= SIZE
	assert(err == Inventory.ERROR.IDX_OUT_OF_BOUNDS)
	return true


func test_delete_at_index() -> bool:
	var info = generate_info_1()
	var iv = Inventory.new(2, info)
	
	iv.add_item(2, 2)
	assert(iv.check_at_index(0) != null)
	
	var err = iv.delete_at_index(0, 999)  # qty ignored in function
	assert(err == Inventory.ERROR.SUCCESS)
	assert(iv.check_at_index(0) == null)
	return true


func test_currently_selected_operations() -> bool:
	var info = generate_info_1()
	var iv = Inventory.new(2, info)
	
	iv.add_item(2, 2)
	iv.currently_selected_idx = 0
	
	var err = iv.remove_at_selected(1)
	assert(err == Inventory.ERROR.SUCCESS)
	assert(iv.get_total_amount(2) == 1)
	
	iv.currently_selected_idx = -1
	err = iv.remove_at_selected(1)
	assert(err == Inventory.ERROR.IDX_OUT_OF_BOUNDS)
	return true
