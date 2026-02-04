extends StatefulPersistenceInterface
#Class that helps the inventory class keep its persistence across sessions
const Inventory := INVENTORY_UIDCLASSREF.Inventory
const InventoryObject := INVENTORY_UIDCLASSREF.InventoryObject
var parent : Inventory = null

func _ready() -> void:
	super()
	parent = get_parent()
	if not (parent is Inventory):
		push_error("Parent %s is not Inventory!!" % parent)
	var data = get_data()
	if data.has("inventory_array"):
		var array : Array = data["inventory_array"]
		var inv_size : int = data["inventory_size"]
		parent.SIZE = inv_size
		for i in range(inv_size):
			if array[2*i] == -1 : parent.array[i] = null; continue #TODO: Hack
			var invobject = InventoryObject.new(array[2*i], array[2*i+1])
			parent.array[i] = invobject
			
	parent.updated.connect(on_inventory_update)

func on_inventory_update(...args) -> void:
	var array : Array[InventoryObject] = parent.array
	var _array_serial : Array = []
	for io in array:
		var id = -1 #TODO: Hack
		var qty = 0
		if io != null:
			id = io.id
			qty = io.qty
		_array_serial.append_array([id, qty])
	save_data({"inventory_array": _array_serial, "inventory_size":parent.SIZE})
	pass
