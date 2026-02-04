extends StateBase
#class_name InventoryStateInvisible
const StateBase := INVENTORY_UIDCLASSREF.StateBase

func enter() -> void:
	super()
	self.entered.emit()

func exit() -> void:
	super()
	self.exited.emit()
