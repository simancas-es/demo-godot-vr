extends SystemTasksCondition
#class_name SystemTasksConditionSignal #Name for json
const SystemTasksCondition := SYSTEMTASKS_UIDCLASSREF.SystemTasksCondition
const SystemTasksLocator := SYSTEMTASKS_UIDCLASSREF.SystemTasksLocator

#Names for json
@export var signal_name : String
@export var locator_id : SYSTEMTASKSSETTINGS.LOCATOR_ID = SYSTEMTASKSSETTINGS.LOCATOR_ID.NO_ID
@export var locator_group : SYSTEMTASKSSETTINGS.LOCATOR_GROUP = SYSTEMTASKSSETTINGS.LOCATOR_GROUP.SYSTEMTASKS_UNGROUPED
var has_been_emitted : bool = false


#Sets the parameters
func set_parameters(dict : Dictionary) -> ERROR:
	for v in dict:
		var val = dict.get(v)
		match v:
			"locator_id":
				if val in SYSTEMTASKSSETTINGS.LOCATOR_ID:
					val = SYSTEMTASKSSETTINGS.LOCATOR_ID[val]
					self.locator_id = val
				else:
					push_warning("Missing locator_id %s." % val)
					return ERROR.ERROR
			"locator_group" :
				if val in SYSTEMTASKSSETTINGS.LOCATOR_GROUP:
					val = SYSTEMTASKSSETTINGS.LOCATOR_GROUP[val]
					self.locator_group = val
				else:
					push_warning("Missing group_name %s." % val)	
					return ERROR.ERROR
			"signal_name": #TODO, check validity...
				val = str(val)
				self.signal_name = val
			
	return ERROR.NO_ERROR

func setup() -> void:
	add_to_group(SYSTEMTASKSSETTINGS.BASE_COND_SIGNAL_GROUP, true)
	oneshot = true	
	connect_signal()
	fulfill_fun = has_emitted_signal

func connect_signal() -> void:
	#Connect to locators of a given locator group that is not the default one,
	#Connect to locators with a particular locator_id
	var parent_array = [] #Connects the signal to the parent object of the locator.
	if locator_group != SYSTEMTASKSSETTINGS.LOCATOR_GROUP.SYSTEMTASKS_UNGROUPED:
		var locators = get_tree().get_nodes_in_group(SYSTEMTASKSSETTINGS.LOCATOR_GROUP.find_key(locator_group))
		for loc in locators:
			if loc is SystemTasksLocator:
				var parent = loc.get_parent()
				parent_array.append(parent)
	
	if locator_id != SYSTEMTASKSSETTINGS.LOCATOR_ID.NO_ID:
		#TODO: Simplify. #Only connect if locator is in a group and has an id? locators alreay
		var locators = get_tree().get_nodes_in_group(SYSTEMTASKSSETTINGS.BASE_LOCATOR_GROUP)
		for loc : SystemTasksLocator in locators:
			if loc is SystemTasksLocator and (loc.locator_id == locator_id):	
				var parent = loc.get_parent()
				parent_array.append(parent)
				
	for object in parent_array:
		if object.has_signal(signal_name):
			if not object.is_connected(signal_name, on_signal): #Prevent duplicate signals
				object.connect(signal_name, on_signal)
		
func on_signal(...args) -> void:
	has_been_emitted = true
	
#Condition Functions
#There is an Object of type T, status S in the world
func has_emitted_signal(world : Node, oneshot : bool) -> bool:
	return has_been_emitted
	
