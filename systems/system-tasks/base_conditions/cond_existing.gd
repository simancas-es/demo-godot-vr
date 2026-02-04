extends SystemTasksCondition
#class_name SystemTasksConditionExisting
const SystemTasksCondition := SYSTEMTASKS_UIDCLASSREF.SystemTasksCondition

@export var number : int = 1 #morethan
@export var locator_group : SYSTEMTASKSSETTINGS.LOCATOR_GROUP


func set_parameters(dict : Dictionary) -> ERROR:
	for v in dict:
		var val : Variant = dict.get(v, null)
		match v:
			"number":
				if typeof(val) == TYPE_STRING:
					val = str(val)
					if val.is_valid_int():
						val = val.to_int()
						self.number = val
					else:
						push_warning("Cant convert to int!! %s." % val)	
						return ERROR.ERROR
				elif typeof(val) == TYPE_INT:
					self.number = val
				else:
					push_warning("Invalid number!! %s." % val)	
					return ERROR.ERROR
			"group_name" : #Name used in the JSON
				if val in SYSTEMTASKSSETTINGS.LOCATOR_GROUP:
					val = SYSTEMTASKSSETTINGS.LOCATOR_GROUP[val] #Transform the value
					self.locator_group = val
				else:
					push_warning("Missing locator_group %s." % val)		
					return ERROR.ERROR
				
	return ERROR.NO_ERROR				

func setup() -> void:
	fulfill_fun = is_object_t_world
	TICK_FREQUENCY_S = 3

#Condition Functions
#There is an Object of type T, status S in the world
func is_object_t_world(world_ : Node, oneshot_ : bool) -> bool:
	# Find candidates by group
	var candidates: Array = world_.get_tree().get_nodes_in_group(SYSTEMTASKSSETTINGS.LOCATOR_GROUP.find_key(locator_group))
	# Check count against requirement
	if candidates.size() >= number:
		return true
	return false
