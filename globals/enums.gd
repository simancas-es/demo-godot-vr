extends Node
class_name ENUMS

const InventoryObjectInformation := INVENTORY_UIDCLASSREF.InventoryObjectInformation



##All the actions that are available for items
enum ACTION {
	INTERACT,
	REMOVE, ## Placeholder
	TAKE, ## Placeholder
	HOLD
}

##Converts the ACTION enum into a project action string
const ACTION_KW := {
	ACTION.INTERACT : "interact",
	ACTION.REMOVE : "remove",
	ACTION.TAKE : "take",
	ACTION.HOLD : "hold"
}

##TODO These interactions should be a class ig
##Save names here and use tr() at the end of the script.
const _action_interact_text = "Interact [{key}]"
const _action_remove_text = "Remove [{key}]"
const _action_take_text = "{name}\nTake [{key}]"
const _action_hold_text = "{name}\nHold [{key}]"

const ACTION_TEXT := {
	ACTION.INTERACT : _action_interact_text ,
	ACTION.REMOVE : _action_remove_text,
	ACTION.TAKE : _action_take_text,
	ACTION.HOLD : _action_hold_text
}

static func get_keystring(action : ACTION) -> String:
	var keystring : String = ENUMS.ACTION_KW[action]
	var keynames : PackedStringArray = UTILS.get_keys_from_action(keystring)
	var keyname : String = "|".join(keynames)
	return keyname

static func format_hints(unformatted_hint : String, playerdata : PlayerData, action : ACTION, item : Interaction) -> String:
	var selected_obj : InventoryObjectInformation = playerdata.get_inventory().get_selected_obj_info()
	
	var selected_name = "???"
	if selected_obj != null: selected_name = selected_obj.get_translated_name(TranslationServer.get_locale())
	
	var formatted_hint = unformatted_hint.format({key=get_keystring(action),
												 name=item.get_hint_name(),
												 selected = selected_name})
	return formatted_hint
	
##Items have to be assigned a bitmask, depending on which layer applies to them
##Items that only interact in a normal environment must be either the 
##ENVIRONMENT_EYE, if they are to be activated by looking at them, or
##ENVIRONMENT_AREA, if they are only activated when the player is on them (area)
##ROOM is for items that only work inside a room (panorama), it is automatically
##assigned to panorama polygons.
##FIXCAM are those that only work when the camera is fixed
##FALCON are those that can only be activated from the falcon view
enum COLLISION_LAYER {
	NONE = 0,
	ENVIRONMENT_EYE = 1 << 0,
	ENVIRONMENT_AREA = 1 << 1,
	ROOM = 1 << 2,
	FIXCAM = 1 << 3,
	FALCON = 1 << 4,
	
	SYSTEMCONCENTRATIONS = 1 << 10, ##Air concentrations.
	SYSTEMPHYSICALCONTROL = 1 <<11, ##Physical control of items
	LADDERS = 1 << 13,
	WALLS = 1 << 14,
	FLOOR = 1 << 15,
	FPVPLAYER = 1 << 19,
} #HACK! Always check that the enums are correctly assigned...
##Changing this might mess up the project!!!

enum VISIBILITY {
	NONE = 0,
	ENV = 1 << 0,
	ROOM = 1 << 1
}

## TRANSLATION. HACK to get automatic exports...
var t = [
		tr(_action_interact_text),
		tr(_action_remove_text),
		tr(_action_take_text),
		tr(_action_hold_text)
		]
