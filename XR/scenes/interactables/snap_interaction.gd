extends Node3D
#This scene allows objects to snap to a point, and given the right conditions, it emits a signal.
#The show model is just decoration. Instead of snapping the object sent, it shows whatever Node3D
#you want it to show. Note that hand poses are tricky to implement if doing this.

@export var item_id : INVENTORYSETTINGS.ID #ID of object that is correct
@export var group : String #Group of objects that is correct
@export var only_itemid : bool = true

@export var snap_require : String = "" #Group required for snapping


@onready var snapzone : XRToolsSnapZone = $SnapZone

@export var show_model : Node3D = null #Model for showing (hides the other one)
var snapped_object : Node3D = null #Object that snapped to this one.

#TODO distance variable for children

const ItemPickable := preload("uid://carmglf74kwfm")

signal has_dropped
signal correct_item_snapped

func _ready() -> void:
	if show_model: show_model.visible = false
	snapzone.snap_require = snap_require
	snapzone.has_picked_up.connect(on_has_picked_up)
	snapzone.has_dropped.connect(on_has_dropped)
	
	if only_itemid:
		snapzone.check_function = func(target : ItemPickable): return target.item_id == item_id	
	pass

func on_has_picked_up(what) -> void:
	snapped_object = what
	if not (what is ItemPickable): return
	
	#Check for correctness
	what = what as ItemPickable
	if (what.item_id == item_id) or (what.is_in_group(group)):
		on_correct_snap()
		snapped_object.visible = false
	pass
	
func on_has_dropped() -> void:
	has_dropped.emit()
	if show_model: show_model.visible = false
	snapped_object.visible = true
	pass
	
	
func on_correct_snap() -> void:
	print("Correct snap %s" % snapped_object.name)
	if show_model: show_model.visible = true
	correct_item_snapped.emit()	
	pass
