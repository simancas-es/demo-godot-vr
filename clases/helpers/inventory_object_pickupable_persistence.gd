extends StatefulPersistenceInterface
#Helper class to help pickup objects persist
class_name InventoryPickupPersistenceHelper

var parent : InventoryPickup = null

enum STATUS {UNDEFINED, AVAILABLE, PICKEDUP}

func _ready() -> void:
	super()
	parent = get_parent()
	if not (parent is InventoryPickup):
		push_error("Parent %s is not InventoryPickup!!" % parent)
	var data = get_data()
	if data.has("was_pickedup"):
		var status = Utils.string_to_enum(STATUS, data["was_pickedup"])
		if status == STATUS.PICKEDUP:
			parent.process_mode = Node.PROCESS_MODE_DISABLED
			parent.queue_free()
	
	parent.successfully_taken.connect(on_taken)

func on_taken() -> void:
	save_data({"was_pickedup": Utils.enum_to_string(STATUS, STATUS.PICKEDUP)})
	pass
