extends Area3D
class_name Interaction

const InteractionHintContextScript := preload("res://clases/fpv/interaction_hint_context.gd")

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
var disabled : bool = false

signal activated(context: InteractionContext) #Do something
signal taken(context: InteractionContext)
signal removed(context: InteractionContext)

signal looked_at(context: InteractionContext) #Get a hint for which key to press
signal dropped_looked_at
signal entered_area
signal exited_area

signal updated_hint #TODO Turn this into a function for the camera

##Override as needed as long as it has the same signature
func available_hint_for_item(playerdata : PlayerData, action : ENUMS.ACTION) -> bool:
	var context: InteractionHintContextScript = InteractionHintContextScript.from_playerdata(playerdata)
	return available_hint_for_context(context, action)

##Override as needed as long as it has the same signature
func available_hint_for_context(context: InteractionHintContextScript, action: ENUMS.ACTION) -> bool:
	var item_id: INVENTORYSETTINGS.ID = INVENTORYSETTINGS.ID.INVALID
	if context != null:
		item_id = context.selected_item_id

	if (action == ENUMS.ACTION.INTERACT) and (item_id in special_hint_text):
		return true
	if action in actions:
		return true
	return false

##Override as needed as long as it has the same signature
##Returns the unformated string for a possible hint of this item
func get_hint_for_item(playerdata : PlayerData, action : ENUMS.ACTION) -> String:
	var context: InteractionHintContextScript = InteractionHintContextScript.from_playerdata(playerdata)
	return get_hint_for_context(context, action)

##Override as needed as long as it has the same signature
##Returns the unformated string for a possible hint of this item
func get_hint_for_context(context: InteractionHintContextScript, action: ENUMS.ACTION) -> String:
	var item_id: INVENTORYSETTINGS.ID = INVENTORYSETTINGS.ID.INVALID
	if context != null:
		item_id = context.selected_item_id

	if (action == ENUMS.ACTION.INTERACT) and (item_id in special_hint_text):
		return tr(special_hint_text[item_id])
	if action in hint_text:
		return tr(hint_text[action])
	elif action in ENUMS.ACTION_TEXT:
		return tr(ENUMS.ACTION_TEXT[action])
	return ""

##Override as needed
func get_hint_name() -> String:
	return tr(name)
	
func is_available_with(context : InteractionContext) -> bool:
	if disabled: return false
	
	return true
