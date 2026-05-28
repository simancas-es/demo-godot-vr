extends Node
## Takes a physics object
## deactivates the physics
## adds it as children
## - this way it keeps mesh and collision logic for tasks
## but can be manipulated with VR

@export var baseroot : Node
@export var unique_name_physics : String

var _object : SystemPhysicalControlObject
var _parent : XRToolsPickable

func _ready() -> void:
	_parent = get_parent()
	_object = baseroot.find_child(unique_name_physics)
	if _object == null:
		push_error("Missing object %s" % unique_name_physics)
		return
	_object.sleeping = true
	#_object.axis_lock_angular_x = false
	#_object.axis_lock_angular_z = false	
	_object.process_mode = Node.PROCESS_MODE_DISABLED
	_parent.dropped.connect(_object.stopped_being_grabbed.emit)
pass
	

func _process(delta: float) -> void:
	if not _object: return
	_object.global_transform = _parent.global_transform
