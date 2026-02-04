extends Interaction
class_name InventoryPickup
const Inventory := INVENTORY_UIDCLASSREF.Inventory

@export var item_id : INVENTORYSETTINGS.ID
@export var qty : int

signal successfully_taken

func _ready() -> void:
	actions = [ENUMS.ACTION.TAKE]
	taken.connect(on_taken)
	
func on_taken(playerdata : PlayerData, _il : FPVInteractionLogic) -> void:
	var inv = playerdata.get_inventory() ##TODO More than one inv?
	var err : INVENTORY_UIDCLASSREF.Inventory.ERROR
	if not item_id in inv.info:
		push_error("Missing InventoryObject information for %s!!" % item_id )
		return
	err = inv.add_item(item_id, qty)
	if err == Inventory.ERROR.SUCCESS:
		print("Picked up %s" % item_id)
		successfully_taken.emit()
		queue_free()

func get_hint_name() -> String:
	var info = InventoryResources.get_info(item_id)
	if info == null: push_error("Missing name for %s" % item_id); return "???"
	var translated_name = info.get_translated_name(TranslationServer.get_locale())
	return translated_name
