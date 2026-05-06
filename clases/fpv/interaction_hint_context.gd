extends RefCounted
class_name InteractionHintContext

const ThisClass := preload("res://clases/fpv/interaction_hint_context.gd")

var selected_item_id: INVENTORYSETTINGS.ID = INVENTORYSETTINGS.ID.INVALID
var selected_item_class: INVENTORYSETTINGS.CLASS = INVENTORYSETTINGS.CLASS.DEFAULT
var selected_item_name: String = ""
var locale: String = "en"

static func from_playerdata(playerdata: PlayerData) -> ThisClass:
	var context: ThisClass = ThisClass.new()
	var current_locale: String = TranslationServer.get_locale()
	if not current_locale.is_empty():
		context.locale = current_locale

	if playerdata == null:
		return context

	var inventory: INVENTORY_UIDCLASSREF.Inventory = playerdata.get_inventory()
	if inventory == null:
		return context

	context.selected_item_id = inventory.get_selected_id()
	var selected_obj: INVENTORY_UIDCLASSREF.InventoryObjectInformation = inventory.get_selected_obj_info()
	if selected_obj == null:
		return context

	context.selected_item_class = selected_obj.CLASS
	context.selected_item_name = selected_obj.get_translated_name(context.locale)
	return context
