extends Area3D
class_name Interaction

enum MODE{ ACTIVATE, LOOK, NOTLOOK}


#Name in base class
@export var actions : Array[ENUMS.ACTION] = [ENUMS.ACTION.INTERACT]

#This is only to override the default action text
@export var hint_text : Dictionary[ENUMS.ACTION, String] ##substitutions are defined in ACTION_TEXT

##substitutiosn as defined in ACTION_TEXT
##intended to use for special interactions such as key-door
##only use the INTERACT ACTION keyword
@export var special_hint_text : Dictionary[INVENTORYSETTINGS.ID, String]



#Collision determined in collision mask


signal activated(by_player : PlayerData, inter_controller : FPVInteractionLogic) #Do something
signal taken(by_player : PlayerData, inter_controller : FPVInteractionLogic)
signal removed(by_player : PlayerData, inter_controller : FPVInteractionLogic)

signal looked_at(by_player : PlayerData, inter_controller : FPVInteractionLogic) #Get a hint for which key to press
signal dropped_looked_at
signal entered_area
signal exited_area

##Override as needed as long as it has the same signature
func available_hint_for_item(playerdata : PlayerData, action : ENUMS.ACTION) -> bool:
	var item_id : INVENTORYSETTINGS.ID = playerdata.get_inventory().get_selected_id()
	if (action == ENUMS.ACTION.INTERACT) and (item_id in special_hint_text):
		return true
	if action in actions:
		return true
	return false

##Override as needed as long as it has the same signature
##Returns the unformated string for a possible hint of this item
func get_hint_for_item(playerdata : PlayerData, action : ENUMS.ACTION) -> String:
	var item_id : INVENTORYSETTINGS.ID = playerdata.get_inventory().get_selected_id()
	if (action == ENUMS.ACTION.INTERACT) and (item_id in special_hint_text):
		return tr(special_hint_text[item_id])
	if action in hint_text:
		return tr(hint_text[action])
	else: return ENUMS.ACTION_TEXT[action]
	return ""

##Override as needed
func get_hint_name() -> String:
	return tr(name)
