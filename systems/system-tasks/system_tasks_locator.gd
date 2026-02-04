extends Node
#class_name SystemTasksLocator
const SystemTasksConditionSignal := SYSTEMTASKS_UIDCLASSREF.SystemTasksConditionSignal
#Abstract class

#Appended to an object to track id and group type
#The purpose of these locator is for conditions and tasks to find the spawned IDs
#and objects to connect to their signals
#TYPICAL USE: Instead of adding an object to a group, we append one of these locators to that item as a child


@export var locator_id : SYSTEMTASKSSETTINGS.LOCATOR_ID = SYSTEMTASKSSETTINGS.LOCATOR_ID.NO_ID
@export var locator_group : SYSTEMTASKSSETTINGS.LOCATOR_GROUP = SYSTEMTASKSSETTINGS.LOCATOR_GROUP.SYSTEMTASKS_UNGROUPED

func _init(_locator_id = null, _locator_group = null) -> void:
	#Transform strings into enum values.
	if _locator_id in SYSTEMTASKSSETTINGS.LOCATOR_ID:
		_locator_id = SYSTEMTASKSSETTINGS.LOCATOR_ID[_locator_id]
	if _locator_group in SYSTEMTASKSSETTINGS.LOCATOR_GROUP:
		_locator_group = SYSTEMTASKSSETTINGS.LOCATOR_ID[_locator_group]
	
	if _locator_id: locator_id = _locator_id
	if _locator_group: locator_group = _locator_group
	

func _ready() -> void:
	add_to_group(SYSTEMTASKSSETTINGS.BASE_LOCATOR_GROUP) #Base group for all of them, independently of their specified group
	var group_name = SYSTEMTASKSSETTINGS.LOCATOR_GROUP.keys()[locator_group]
	add_to_group(group_name)
	
	#Look for all the signal conditions and ask to connect if they havent.
	var cond_signals = get_tree().get_nodes_in_group(SYSTEMTASKSSETTINGS.BASE_COND_SIGNAL_GROUP)
	for cs : SystemTasksConditionSignal in cond_signals:
		cs.connect_signal()
