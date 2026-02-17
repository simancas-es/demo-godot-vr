extends Node
#Add to XRToolsHand, it will find the Skeleton.
var parent : XRToolsHand = null
@onready var ba3d : BoneAttachment3D = $BoneAttachment3D 

@export var bone_name : StringName = ""
@export var bone_index : int = -1

func _ready() -> void:
	ba3d.bone_name = bone_name
	ba3d.bone_idx = bone_index
	
	parent = get_parent()
	if not (parent is XRToolsHand): push_error("Parent is not a hand!!"); return
	
	#
	#var skeleton  : Skeleton3D = XRTools.find_xr_child(parent, "*", "Skeleton3D")
	#skeleton.add_child(ba3d)
	#
	
	
