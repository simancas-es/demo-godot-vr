extends StatefulPersistenceInterface
class_name StatefulPersistenceInterfaceSimpleAttributes
#All simple attributes: int, float, bool, String
@export var signalname : String #Signal from the parent that will trigger an update
@export var saved_attributes : Array[String] #Name of the variables that will be pulled

var target : Object = null # target for attributes. parent if none.

func _ready() -> void:
	super()
	if ! target: target = get_parent()
	if not (target is Object):
		push_error("Parent %s is not Object!!" % target)
	var data = get_data()
	for key in saved_attributes:
		if data.has(key) and (key in target):
			var p_attr = target.get(key)
			var attr = data.get(key)
			match typeof(p_attr):
				TYPE_BOOL, TYPE_STRING:
					target.set(key, attr)
				TYPE_FLOAT:
					target.set(key, float(attr))
				TYPE_INT:
					target.set(key, int(attr))
				TYPE_ARRAY:
					if attr is Array:
						var valid = true
						if p_attr.size() > 0:
							var elem_type = typeof(p_attr[0])							
							for v in attr:
								if typeof(v) != elem_type:
									push_error("Array type mismatch for attribute %s" % key)
									valid = false; break
						if valid:
							var arr : Array = target.get(key)
							arr.resize(attr.size())
							for i in attr.size():
								arr[i] = attr[i]
							pass
					else:
						push_error("Expected array for attribute %s but got %s" % [key, typeof(attr)])
				_:
					push_error("Incorrect Stateful persistence simple attribute %s" % key)
				
				
				
	if signalname != "":
		target.connect(signalname, on_signal)
		
func poll_data() -> void:
	var saved_dict : Dictionary = {}
	for key in saved_attributes:
		if key in target:
			var attr = target.get(key)
			saved_dict[key] = attr
	save_data(saved_dict)
	pass

func on_signal() -> void:
	poll_data()
		
		
		
		
