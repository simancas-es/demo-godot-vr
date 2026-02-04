extends StatefulPersistenceInterface
class_name StatefulPersistenceInterfacePosition

@export var polling_time_s : float = 1.0 #Time between position pollings
#Polls the position from the parent object automatically

var parent : Node3D = null

func _ready() -> void:
	super()
	parent = get_parent()
	if not (parent is Node3D):
		push_error("Parent %s is not Node3D!! Position wont be saved!!" % parent)
	var data = get_data()
	if data.has("position"):
		parent.global_transform.origin = Utils.string_to_vector3(data["position"])
		
func poll_data() -> void:
	var pos = parent.global_transform.origin
	#save it:
	save_data({"position": pos})
	pass
	
	
var _time_s : float = polling_time_s
func _process(delta: float) -> void:
	_time_s -= delta
	if _time_s <= 0.0:
		poll_data()
		_time_s = polling_time_s
		
		
		
		
		
