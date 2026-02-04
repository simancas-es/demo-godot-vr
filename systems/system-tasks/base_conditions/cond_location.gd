extends SystemTasksConditionSignal
#class_name SystemTasksConditionLocation #Name for json
const SystemTasksConditionSignal := SYSTEMTASKS_UIDCLASSREF.SystemTasksConditionSignal


#Names for json
@export var locator_id_who : SYSTEMTASKSSETTINGS.LOCATOR_ID = SYSTEMTASKSSETTINGS.LOCATOR_ID.NO_ID

func setup() -> void:	
	super() #Inherits setup
	signal_name = "body_entered" #for Area3D

#Sets the parameters
func set_parameters(dict : Dictionary) -> ERROR:
	super(dict)
	for v in dict:
		var val = dict.get(v)
		match v:
			"locator_id_where", "locator_where":
				if val in SYSTEMTASKSSETTINGS.LOCATOR_ID:
					val = SYSTEMTASKSSETTINGS.LOCATOR_ID[val]
					self.locator_id = val
				else:
					push_warning("Missing locator_id_where %s." % val)
					return ERROR.ERROR
			"locator_group_where" :
				if val in SYSTEMTASKSSETTINGS.LOCATOR_GROUP:
					val = SYSTEMTASKSSETTINGS.LOCATOR_GROUP[val]
					self.locator_group = val
				else:
					push_warning("Missing group_name %s." % val)	
					return ERROR.ERROR
			"locator_id_who", "locator_who":
				if val in SYSTEMTASKSSETTINGS.LOCATOR_ID:
					val = SYSTEMTASKSSETTINGS.LOCATOR_ID[val]
					self.locator_id_who = val
				else:
					push_warning("Missing locator_id_who %s." % val)
					return ERROR.ERROR
	if locator_id_who == SYSTEMTASKSSETTINGS.LOCATOR_ID.NO_ID:
		return ERROR.ERROR
	return ERROR.NO_ERROR

#Signal is already connected to the parent of the locator pair
func on_signal(...args) -> void:
	var _body_parent : Node3D = args[0] #TODO
	for c in _body_parent.get_children():
		if c is SYSTEMTASKS_UIDCLASSREF.SystemTasksLocator:
			if c.locator_id == locator_id_who:
				has_been_emitted = true

	
